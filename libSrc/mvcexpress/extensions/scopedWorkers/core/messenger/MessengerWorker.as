package mvcexpress.extensions.scopedWorkers.core.messenger {
import flash.net.registerClassAlias;
import flash.utils.describeType;
import flash.utils.getDefinitionByName;
import flash.utils.getQualifiedClassName;

import mvcexpress.core.messenger.Messenger;
import mvcexpress.core.namespace.pureLegsCore;
import mvcexpress.extensions.scopedWorkers.modules.ModuleScopedWorker;

public class MessengerWorker extends Messenger {


	private var isReady:Boolean;// = false;

	private var pendingTypes:Vector.<String> = new <String>[];
	private var pendingParams:Vector.<Object> = new <Object>[];

	public function MessengerWorker($moduleName:String) {
		super($moduleName);
	}


	override public function send(type:String, params:Object = null):void {
//		trace("    MessengerWorker     send", type, params);

		if (isReady) {

			if (params) {
				if (ModuleScopedWorker.doAutoRegisterClasses) {
					var paramClass:Class = params.constructor;
					var qualifiedName:String = ModuleScopedWorker.$classAliasRegistry.classes[paramClass];
					if (!qualifiedName) {
						parseObject(params.constructor);
					}
				}
			}

			use namespace pureLegsCore;

			ModuleScopedWorker.debug_sendMessage(type, params);

		} else {
			pendingTypes.push(type);
			pendingParams.push(params);
		}

	}

	pureLegsCore function ready():void {
		isReady = true;

		while (pendingTypes.length) {
			send(pendingTypes.pop(), pendingParams.pop());
		}
	}

	private function parseObject(paramClass:Class):void {
		use namespace pureLegsCore;

		// TODO : check if object class constructor has no parometers.

		qualifiedName = getQualifiedClassName(paramClass).replace("::", ".");

		//trace("start registration ... ", qualifiedName);
		registerClassAlias(qualifiedName, paramClass);

		ModuleScopedWorker.$classAliasRegistry.classes[paramClass] = qualifiedName;

		ModuleScopedWorker.startClassRegistration(qualifiedName);

		// handle meber types.

		var classDescription:XML = describeType(paramClass);
		var factoryNodes:XMLList = classDescription.factory.*;
		var nodeCount:int = factoryNodes.length();
		for (var i:int; i < nodeCount; i++) {
			var node:XML = factoryNodes[i];
			var nodeName:String = node.name();
			if (nodeName == "variable" || nodeName == "accessor") {
//				trace("Type", factoryNodes[i].@type);

				var memberClass:Class = getDefinitionByName(factoryNodes[i].@type) as Class;

				// TODO : optimize for better performance. (local static dictionary?)

				var qualifiedName:String = ModuleScopedWorker.$classAliasRegistry.classes[memberClass];
				if (!qualifiedName) {
					parseObject(memberClass);
				}
			}
		}


	}
}
}
