const {test}=require('node:test');
const assert=require('node:assert/strict');
const vm=require('node:vm');
const fs=require('node:fs');
const path=require('node:path');
function runtime(){
  const objects={hero:{x:100,y:0,active:true},tree:{x:0,y:0,active:true}};
  const elements={prompt:{style:{}}},events=[],actions=[];
  const scene={children:{getByName:name=>objects[name]}};
  const context=vm.createContext({window:{},Shiny:{addCustomMessageHandler(){}},
    console,testScene:scene,document:{getElementById:id=>elements[id]},
    Phaser:{Math:{Distance:{Between:(x,y,a,b)=>Math.hypot(x-a,y-b)}}}});
  context.GameBridge=context.window.GameBridge={};
  vm.runInContext(fs.readFileSync(path.join(__dirname,'../../inst/www/phaser-game.js'),'utf8'),context);
  vm.runInContext('scene = testScene;',context);
  context.runBrowserActionList=(spec,...actors)=>actions.push({spec,actors});
  context.sendPhaserEvent=(id,payload)=>{if(id)events.push({inputId:id,...payload})};
  return {context,objects,elements,events,actions};
}
test('legacy point triggers report edges and update shared HTML visibility',()=>{
  const {context:c,objects:o,elements,events}=runtime();
  c.addProximityTrigger('point','hero',0,0,20,'prompt',null,'point_state');
  assert.equal(elements.prompt.style.display,'none');
  o.hero.x=10;c.updateProximityTriggers();c.updateProximityTriggers();
  assert.equal(events.length,1);assert.equal(events[0].active,true);
  c.addProximityTrigger('other','hero',0,0,50,'prompt',null,null);
  o.hero.x=30;c.updateProximityTriggers();assert.equal(events.at(-1).event,'leave');
  assert.equal(elements.prompt.style.display,'block');
  o.hero.x=60;c.updateProximityTriggers();assert.equal(elements.prompt.style.display,'none');
});
test('moving targets, missing/inactive objects and map changes produce proper edges',()=>{
  const {context:c,objects:o,events,actions}=runtime();c.GameBridge.activeMapKey='outside';
  c.addProximityTrigger('moving','hero',null,null,20,null,'outside','moving_state','tree','both',false,[{show:'hint'}]);
  o.tree.x=90;c.updateProximityTriggers();assert.equal(events.at(-1).targetX,90);
  assert.equal(actions.at(-1).actors[1],o.tree);
  o.tree.active=false;c.updateProximityTriggers();assert.equal(events.at(-1).event,'leave');
  o.tree.active=true;c.updateProximityTriggers();
  o.hero.active=false;c.updateProximityTriggers();assert.equal(events.at(-1).active,false);
  o.hero.active=true;c.updateProximityTriggers();
  c.GameBridge.activeMapKey='inside';c.updateProximityTriggers();assert.equal(events.at(-1).event,'leave');
  c.GameBridge.activeMapKey='outside';c.updateProximityTriggers();
  delete o.tree;c.updateProximityTriggers();assert.equal(events.at(-1).event,'leave');
  assert.equal(events.filter(e=>e.event==='enter').length,4);
});
test('one-time filtered reactions keep detecting and can be rearmed by replacement',()=>{
  const {context:c,objects:o,events,elements}=runtime();
  c.addProximityTrigger('once','hero',0,0,20,'prompt',null,'state',null,'enter',true,[]);
  o.hero.x=0;c.updateProximityTriggers();o.hero.x=100;c.updateProximityTriggers();
  assert.equal(elements.prompt.style.display,'none');
  o.hero.x=0;c.updateProximityTriggers();assert.equal(events.length,1);
  c.addProximityTrigger('once','hero',0,0,20,'prompt',null,'state',null,'enter',true,[]);
  assert.equal(events.length,2);
  c.addProximityTrigger('leave','hero',0,0,20,null,null,'leave_state',null,'leave',true,[]);
  assert.equal(events.length,2);o.hero.x=100;c.updateProximityTriggers();
  assert.equal(events.at(-1).inputId,'leave_state');assert.equal(events.at(-1).event,'leave');
});
