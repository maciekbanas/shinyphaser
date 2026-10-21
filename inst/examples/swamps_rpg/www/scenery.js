// Example-specific depth sorting; gameplay does not round-trip through Shiny.
window.configureSwampsScenery = function (actorNames) {
  const scene = window.game.scene.scenes[0];
  if (scene.swampsSceneryUpdate) return;

  // Only the hero's feet collide. The full 100px sprite would block the canopy.
  withSprite("hero", function (hero) {
    hero.body.setSize(32, 18);
    hero.body.setOffset(34, 72);
  });

  const update = function () {
    actorNames.forEach(function (name) {
      const actor = scene.children.getByName(name);
      if (actor) actor.setDepth(actor.y + actor.displayHeight / 2 - 10);
    });
    // Fixed HUD elements must stay above every world-space depth.
    scene.children.list.forEach(function (object) {
      if (object.scrollFactorX === 0 && object.scrollFactorY === 0) {
        object.setDepth(10000);
      }
    });
  };
  scene.swampsSceneryUpdate = update;
  scene.events.on("postupdate", update);
  scene.events.once("shutdown", function () {
    scene.events.off("postupdate", update);
    delete scene.swampsSceneryUpdate;
  });
  update();
};
