//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <printing/printing_plugin.h>
#include <public_file_saver/public_file_saver_plugin_c_api.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  PrintingPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("PrintingPlugin"));
  PublicFileSaverPluginCApiRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("PublicFileSaverPluginCApi"));
}
