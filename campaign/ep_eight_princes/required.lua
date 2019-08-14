

-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
--
--	REQUIRED FILES
--
--	Add any files that need to be loaded for this campaign here
--
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------

package.path = package.path .. ";" .. cm:get_campaign_folder() .. "/?.lua";

--	general campaign behaviour
force_require("3k_campaign_setup");

--	campaign-specific files
require("ep_eight_princes_start");

require("lib_utility_functions");

require("3k_campaign_interventions");
require("3k_campaign_experience");
require("3k_campaign_faction_council");
require("3k_campaign_ancillaries");
require("3k_campaign_ancillaries_master_craftsmen");
require("3k_campaign_ancillaries_ambient_spawning");
require("3k_campaign_man_of_the_hour");
require("3k_campaign_traits");
require("3k_campaign_character_relationships");
require("3k_campaign_cdir_events_manager");
require("ep_events");
require("ep_campaign_default_diplomacy");
require("ep_storybook");
require("ep_gating");
require("ep_emperor_manager")