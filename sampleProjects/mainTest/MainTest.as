package mainTest {
import mvcexpress.extensions.workers.display.WorkerSprite;

import utils.debug.Stats;

public class MainTest extends WorkerSprite {

	override protected function init():void {
		trace("MainTest");

		var module:MainTestModule = new MainTestModule();
		module.start(this);

		this.stage.frameRate = 60;

		var stats:Stats = new Stats(120, 0, 0, false, true, true)
		this.addChild(stats);

	}


}
}
