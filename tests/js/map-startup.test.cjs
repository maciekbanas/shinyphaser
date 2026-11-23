const {test} = require('node:test');
const assert = require('node:assert/strict');
const {readFileSync} = require('node:fs');
const {join} = require('node:path');
const vm = require('node:vm');

test('initial map loading preserves queued visibility and player placement', () => {
  const bridge = {};
  const context = vm.createContext({window: {GameBridge: bridge}, GameBridge: bridge, Shiny: {addCustomMessageHandler() {}}});
  vm.runInContext(readFileSync(join(__dirname, '../../inst/www/phaser-game.js'), 'utf8'), context);
  const layer = {};
  for (const method of ['setCollisionByProperty', 'setDepth', 'setVisible', 'setActive']) {
    layer[method] = () => layer;
  }
  let complete;
  context.testScene = {
    load: {tilemapTiledJSON() {}, image() {}, once(event, fn) {complete = fn;}, start() {}},
    make: {tilemap: () => ({addTilesetImage() {}, createLayer: () => layer})}
  };
  const activations = [];
  context.recordActivation = (...args) => activations.push(args);
  vm.runInContext('scene = testScene; activateMap = recordActivation;', context);
  const args = ['clearing', 'hero', 150, 150, ['mushroom'], ['good_spirit', 'skeleton_3']];
  bridge.pendingActiveMap = {mapKey: 'clearing', args};
  context.addMap('clearing', 'clearing.json', [], [], 'terrain');
  complete();
  assert.deepEqual(activations, [args]);
});
