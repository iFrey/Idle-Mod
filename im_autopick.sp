#pragma semicolon 1
#include <sourcemod>
#include <cstrike>
#include <sdktools>

#define PLUGIN_VERSION "0.1.0"

new Handle:cv_h_autopick = INVALID_HANDLE;
new cv_autopick;

public Plugin:myinfo =
{
  name = "[CS:GO] Idle Mod: Autopick",
  author = "iFrey",
  description = "Autopick of Idle Mod",
  version = PLUGIN_VERSION,
  url = "In Progress"
}

new firstPlayer=0;

public OnPluginStart()
{

  /*cv_h_autopick  = CreateConVar("im_autopick", "1", "(0 = Disabled, 1 = Enabled)", FCVAR_NONE, true, 0.0, true, 1.0);
  HookConVarChange(cv_h_autopick , OnCVarChange);
  cv_autopick = GetConVarInt(cv_h_autopick);

  AutoExecConfig(true, "idle_mod");*/

  /*if (cv_autopick)*/	ActivateAutopick();

}

/*public OnCVarChange(Handle:cvar, const String:oldvalue[], const String:newvalue[])
{
  if(cvar == cv_h_autopick)
  {
    cv_autopick = StringToInt(newvalue);
    if (cv_autopick)	ActivateAutopick();
    else DeactivateAutopick();
  }
}*/

public Action:Event_OnPlayerActivated(Handle:event, const String:name[], bool:dontBroadcast)
{
  new client = GetClientOfUserId(GetEventInt(event, "userid"));
  AutoPick(client);
  return Plugin_Continue;
}

AutoPick(client)
{
  new ClientTeam;
  ClientTeam = GetClientTeam(client);

  if (!(ClientTeam==CS_TEAM_T || ClientTeam==CS_TEAM_CT))
  {
    new T_Team_Count = GetTeamClientCount(CS_TEAM_T);
    new CT_Team_Count = GetTeamClientCount(CS_TEAM_CT);
    if (T_Team_Count<CT_Team_Count)
    {
      ChangeClientTeam(client, CS_TEAM_T); //Goes to T Team
    }
    else
    {
      ChangeClientTeam(client, CS_TEAM_CT); //Goes to CT Team
    }
  }
}

ActivateAutopick()
{
  HookEvent("player_activate", Event_OnPlayerActivated, EventHookMode_Post);
}

/*DeactivateAutopick()
{
  UnhookEvent("player_activate", Event_OnPlayerActivated, EventHookMode_Post);
}*/
