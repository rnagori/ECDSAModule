using ReactNative.Bridge;
using System;
using System.Collections.Generic;
using Windows.ApplicationModel.Core;
using Windows.UI.Core;

namespace Kye.Pair.Manager.RNKyePairManager
{
    /// <summary>
    /// A module that allows JS to share data.
    /// </summary>
    class RNKyePairManagerModule : NativeModuleBase
    {
        /// <summary>
        /// Instantiates the <see cref="RNKyePairManagerModule"/>.
        /// </summary>
        internal RNKyePairManagerModule()
        {

        }

        /// <summary>
        /// The name of the native module.
        /// </summary>
        public override string Name
        {
            get
            {
                return "RNKyePairManager";
            }
        }
    }
}
