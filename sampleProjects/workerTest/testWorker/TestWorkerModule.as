package workerTest.testWorker {
import flash.net.registerClassAlias;
import flash.system.Worker;

import mvcexpress.extensions.workers.core.WorkerManager;
import mvcexpress.extensions.workers.modules.ModuleWorker;

import constants.WorkerIds;
import workerTest.mainWorker.data.MainDataSwapTestVO;

/**
 * @author rbanevicius
 */
public class TestWorkerModule extends ModuleWorker {

	public function TestWorkerModule() {
		super(WorkerIds.TEST_WORKER);
	}

	override protected function onInit():void {
		//MonsterDebugger.initialize(this);
		/**debug:worker**/trace("  -[" + moduleName + "]" + "TestWorkerModule:onInit();");

		registerClassAlias("workerTest.mainWorker.data.MainDataSwapVO", MainDataSwapTestVO);


		mediatorMap.mediateWith(this, TestWorkerModuleMediator);

	}


}
}