

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
require("3k_early_start");

require("3k_campaign_interventions");
require("3k_campaign_experience");
require("3k_campaign_faction_council");
require("3k_campaign_ancillaries");
require("3k_campaign_ancillaries_master_craftsmen");
require("3k_campaign_ancillaries_ambient_spawning");
require("3k_campaign_man_of_the_hour");
require("3k_campaign_gating");
require("3k_tutorial_missions");
require("3k_historical_missions");
require("3k_progression_missions");
require("3k_campaign_traits");
require("3k_campaign_progression");
require("3k_campaign_endgame");
require("3k_campaign_commentary_events");
require("3k_campaign_default_diplomacy");
require("3k_ytr_campaign_ancillaries");
require("3k_ytr_campaign_traits");
require("3k_ytr_yellow_turban_assignments");
require("3k_ytr_emperor_ascension");
require("3k_campaign_character_relationships");
require("3k_campaign_tutorial");
require("3k_campaign_historical_events");
require("3k_campaign_cdir_events_manager");
require("3k_extended_tutorial");
