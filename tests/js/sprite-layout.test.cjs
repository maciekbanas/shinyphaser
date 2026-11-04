const {test} = require('node:test');
const assert = require('node:assert/strict');
const {EventEmitter} = require('node:events');
const {readFileSync} = require('node:fs');
const {join} = require('node:path');
const vm = require('node:vm');

function runtime() {
  const scene = {events: new EventEmitter()};
  const context = vm.createContext({window: {}, scene, console});
  context.GameBridge = context.window.GameBridge = {};
  vm.runInContext(readFileSync(join(__dirname, '../../inst/www/phaser-sprite.js'), 'utf8'), context);
  function add(name) {
    const sprite = new EventEmitter();
    Object.assign(sprite, {scene, active: true, y: 100, depth: 0});
    sprite.setDepth = depth => {sprite.depth = depth;};
    sprite.body = {
      setSize: (...args) => {sprite.size = args;},
      setOffset: (...args) => {sprite.offset = args;}
    };
    scene[name] = sprite;
    context.applyPendingSpriteActions(name);
    return sprite;
  }
  return {context, scene, add};
}

test('body sizing and automatic depth survive asynchronous sprite creation', () => {
  const {context, scene, add} = runtime();
  context.setSpriteBodySize('hero', 32, 18, 34, 72);
  context.setSpriteDepthByY('hero', 40, true);
  const hero = add('hero');
  assert.deepEqual(hero.size, [32, 18, false]);
  assert.deepEqual(hero.offset, [34, 72]);
  assert.equal(hero.depth, 140);
  hero.y = 350;
  scene.events.emit('postupdate');
  assert.equal(hero.depth, 390);
});

test('reconfiguration, disabling and fixed depth do not leak listeners', () => {
  const {context, scene, add} = runtime();
  const hero = add('hero');
  context.setSpriteDepthByY('hero', 40, true);
  context.setSpriteDepthByY('hero', 20, true);
  assert.equal(scene.events.listenerCount('postupdate'), 1);
  assert.equal(scene.events.listenerCount('shutdown'), 1);
  assert.equal(hero.listenerCount('destroy'), 1);
  assert.equal(hero.depth, 120);
  context.setSpriteDepthByY('hero', 0, false);
  hero.y = 500;
  scene.events.emit('postupdate');
  assert.equal(hero.depth, 120);
  assert.equal(scene.events.listenerCount('postupdate'), 0);
  context.setSpriteDepthByY('hero', 40, true);
  context.setSpriteDepth('hero', 7);
  scene.events.emit('postupdate');
  assert.equal(hero.depth, 7);
  assert.equal(scene.events.listenerCount('shutdown'), 0);
  assert.equal(hero.listenerCount('destroy'), 0);
});

test('destroying one actor preserves another; scene shutdown clears the rest', () => {
  const {context, scene, add} = runtime();
  const hero = add('hero');
  const enemy = add('enemy');
  context.setSpriteDepthByY('hero', 40, true);
  context.setSpriteDepthByY('enemy', 10, true);
  hero.emit('destroy');
  assert.equal(scene.events.listenerCount('postupdate'), 1);
  enemy.y = 250;
  scene.events.emit('postupdate');
  assert.equal(enemy.depth, 260);
  scene.events.emit('shutdown');
  assert.equal(scene.events.listenerCount('postupdate'), 0);
  assert.equal(enemy.listenerCount('destroy'), 0);
});
