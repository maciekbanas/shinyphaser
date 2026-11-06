const {test}=require('node:test');const assert=require('node:assert/strict');
const {EventEmitter}=require('node:events');const vm=require('node:vm');
const fs=require('node:fs');const path=require('node:path');
function runtime(){
  const objects={},steps=[],stops=[];
  const scene={events:new EventEmitter(),time:{now:0},children:{getByName:n=>objects[n]},
    tweens:{isTweening:s=>Boolean(s.moving)}};
  const c=vm.createContext({window:{},scene,console,Phaser:{Math:{Distance:{Between:(x,y,a,b)=>Math.hypot(x-a,y-b)},RND:{pick:a=>a[0]}}}});
  c.GameBridge=c.window.GameBridge={};
  vm.runInContext(fs.readFileSync(path.join(__dirname,'../../inst/www/phaser-sprite.js'),'utf8'),c);
  c.stopSpriteMotion=n=>{stops.push(n);if(objects[n])objects[n].moving=false};
  c.setSpriteInMotion=(...args)=>{steps.push(args);objects[args[0]].moving=true};
  function add(name,x=0,y=0){const s=Object.assign(new EventEmitter(),{name,scene,x,y,active:true});objects[name]=s;scene[name]=s;c.applyPendingSpriteActions(name);return s}
  function tick(t){scene.time.now=t;scene.events.emit('postupdate')}
  const config=(mode,other={})=>({mode,target_name:null,speed:100,distance:45,interval:100,...other});
  return {c,scene,objects,steps,stops,add,tick,config};
}
test('following waits for loading, caps steps and pauses for target and hit reactions',()=>{
  const {c,steps,add,tick,config}=runtime();
  c.setSpriteMovement('enemy',config('follow',{target_name:'hero'}));
  const enemy=add('enemy'),hero=add('hero',30,0);tick(0);
  assert.deepEqual(steps[0],['enemy',1,0,100,30]);tick(200);assert.equal(steps.length,1);
  enemy.moving=false;c.GameBridge.forcedAnimations.enemy={key:'damage'};tick(300);assert.equal(steps.length,1);
  enemy.moving=true;tick(350);assert.equal(enemy.moving,true);
  delete c.GameBridge.forcedAnimations.enemy;hero.active=false;tick(400);assert.equal(steps.length,1);
  hero.active=true;hero.x=0;hero.y=90;tick(500);assert.deepEqual(steps[1],['enemy',0,1,100,45]);
  enemy.active=false;tick(600);assert.equal(enemy.moving,false);
});
test('wandering throttles steps; replacement, stop, destruction and shutdown clean up',()=>{
  const {c,scene,steps,add,tick,config}=runtime();const enemy=add('enemy');
  c.setSpriteMovement('enemy',config('wander',{interval:1500}));tick(0);enemy.moving=false;tick(1499);assert.equal(steps.length,1);tick(1500);assert.equal(steps.length,2);
  c.GameBridge.forcedAnimations.enemy={key:'damage'};
  c.setSpriteMovement('enemy',config('wander'));assert.equal(enemy.moving,true);assert.equal(scene.events.listenerCount('postupdate'),1);
  c.setSpriteMovement('enemy',config('stop'));assert.equal(scene.events.listenerCount('postupdate'),0);assert.equal(enemy.moving,false);
  c.setSpriteMovement('enemy',config('wander'));enemy.emit('destroy');assert.equal(scene.events.listenerCount('postupdate'),0);
  c.setSpriteMovement('enemy',config('wander'));scene.events.emit('shutdown');assert.equal(scene.events.listenerCount('postupdate'),0);assert.equal(enemy.listenerCount('destroy'),0);
});
