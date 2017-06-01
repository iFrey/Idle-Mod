#pragma semicolon 1
#include <sourcemod>
#include <cstrike>
#include <sdktools>

#define PLUGIN_VERSION "0.1.0"

// global variables
new g_TimeAFK[65];

new Handle:cv_h_smartimmunity = INVALID_HANDLE;
new cv_smartimmunity;

public Plugin:myinfo =
{
  name = "[CS:GO] Idle Mod: Smart Immunity",
  author = "iFrey",
  description = "Immunity to non-AFK players of Idle Mod",
  version = PLUGIN_VERSION,
  url = "In Progress"
}

public OnPluginStart()
{

  /*cv_h_smartimmunity  = CreateConVar("im_smartimmunity", "1", "(0 = Disabled, 1 = Enabled)", FCVAR_NONE, true, 0.0, true, 1.0);
  HookConVarChange(cv_h_smartimmunity , OnCVarChange);
  cv_smartimmunity = GetConVarInt(cv_h_smartimmunity);

  AutoExecConfig(true, "idle_mod");

  if (cv_smartimmunity)*/	ActivateSmartImmunity();

}

/*public OnCVarChange(Handle:cvar, const String:oldvalue[], const String:newvalue[])
{
  if(cvar == cv_h_smartimmunity)
  {
    cv_smartimmunity = StringToInt(newvalue);
    if (cv_smartimmunity)	ActivateSmartImmunity();
    else DeactivateSmartImmunity();
  }
}*/

public Action:Event_OnPlayerActivated(Handle:event, const String:name[], bool:dontBroadcast)
{
  g_TimeAFK[GetClientOfUserId(GetEventInt(event, "userid"))] = 1;
}

public Action:Event_RoundStart(Handle:event, const String:name[], bool:dontBroadcast)
{
  CreateTimer(20.0, Timer_CheckAFK, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
  return Plugin_Continue;
}

public Action:Timer_CheckAFK(Handle:Timer)
{
  for(new i = 1; i <= GetMaxClients() && IsRealPlayer(i); i++)
  {
    //He is AFK
    if (g_TimeAFK[i] == 1)
    {
      //Remove immunity
      SetEntProp(i, Prop_Data, "m_takedamage", 2, 1);
    }
    else
    {
      g_TimeAFK[i] = 1;
    }
  }
}

public Action:Event_OnPlayerFootstep(Handle:event, const String:name[], bool:dontBroadcast)
{
  GivePlayerImmunity(GetClientOfUserId(GetEventInt(event, "userid")));
  return Plugin_Continue;
}

public Action:Event_OnWeaponFire(Handle:event, const String:name[], bool:dontBroadcast)
{
  GivePlayerImmunity(GetClientOfUserId(GetEventInt(event, "userid")));
  return Plugin_Continue;
}

GivePlayerImmunity(client)
{
  if (g_TimeAFK[client] == 1 && IsRealPlayer(client))
  {
    //NO AFK flag
    g_TimeAFK[client] = 0;
    //Give immunity
    SetEntProp(client, Prop_Data, "m_takedamage", 0, 1);
  }
}

bool:IsRealPlayer(client)
{
  if(!IsClientConnected(client)
    || !IsClientInGame(client)
    || IsFakeClient(client))
  {
    return false;
  }
  return true;
}

ActivateSmartImmunity()
{
  HookEvent("round_start", Event_RoundStart, EventHookMode_Pre);
  HookEvent("player_footstep", Event_OnPlayerFootstep, EventHookMode_Pre);
  HookEvent("weapon_fire", Event_OnWeaponFire, EventHookMode_Pre);
  HookEvent("player_activate", Event_OnPlayerActivated, EventHookMode_Post);
}

/*DeactivateSmartImmunity()
{
  UnhookEvent("round_start", Event_RoundStart, EventHookMode_Pre);
  UnhookEvent("player_footstep", Event_OnPlayerFootstep, EventHookMode_Pre);
  UnhookEvent("weapon_fire", Event_OnWeaponFire, EventHookMode_Pre);
  UnhookEvent("player_activate", Event_OnPlayerActivated, EventHookMode_Post);
}*/
