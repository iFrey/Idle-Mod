#pragma semicolon 1
#include <sourcemod>
#include <cstrike>
#include <sdktools_functions>

#define PLUGIN_VERSION "0.1.0"

#define CASH 16000
#define CASH_PROP "m_iAccount"

new Handle:cv_h_infinitecash = INVALID_HANDLE;
new cv_infinitecash;

new Handle:cv_h_deleteweapondrop = INVALID_HANDLE;
new cv_deleteweapondrop;

new WeaponOffset;

public Plugin:myinfo =
{
  name = "[CS:GO] Idle Mod: Infinite cash",
  author = "iFrey",
  description = "Infinite cash and delete dropped weapons of Idle Mod",
  version = PLUGIN_VERSION,
  url = "In Progress"
}

public OnPluginStart()
{
  /*cv_h_infinitecash = CreateConVar("im_infinitecash", "1", "(0 = Disabled, 1 = Enabled)", FCVAR_NONE, true, 0.0, true, 1.0);
  HookConVarChange(cv_h_infinitecash, OnCVarChange);
  cv_infinitecash = GetConVarInt(cv_h_infinitecash);

  cv_h_deleteweapondrop = CreateConVar("im_deleteweapondrop", "1", "(0 = Disabled, 1 = Enabled)", FCVAR_NONE, true, 0.0, true, 1.0);
  HookConVarChange(cv_h_deleteweapondrop, OnCVarChange);
  cv_deleteweapondrop = GetConVarInt(cv_h_deleteweapondrop);

  if (cv_infinitecash)*/	ActivateInfiniteCash();
}

/*public OnCVarChange(Handle:cvar, const String:oldvalue[], const String:newvalue[])
{
  if(cvar == cv_h_infinitecash)
  {
    cv_infinitecash = StringToInt(newvalue);
    if (cv_infinitecash) ActivateInfiniteCash();
    else DeactivateInfiniteCash();
  }
}*/

public Action:Event_OnItemPurchased(Handle:event, const String:name[], bool:dontBroadcast)
{
  new client = GetClientOfUserId(GetEventInt(event,"userid"));
  SetEntProp(client, Prop_Send, CASH_PROP, CASH);
  if (cv_deleteweapondrop)
  {
  CreateTimer(1.0, DeleteDrop,client);
  }
  return Plugin_Continue;
}

public Action:DeleteDrop(Handle:timer, any:client)
{
  new maxent = GetMaxEntities(), String:weapon[64];
  for (new i=GetMaxClients();i<maxent;i++)
  {
    if ( IsValidEdict(i) && IsValidEntity(i) )
    {
      GetEdictClassname(i, weapon, sizeof(weapon));
      if ( ( StrContains(weapon, "weapon_") != -1 || StrContains(weapon, "item_") != -1 ) && GetEntDataEnt2(i, WeaponOffset) == -1 )
        RemoveEdict(i);
      }
    }
}

ActivateInfiniteCash()
{
  HookEvent("item_purchase", Event_OnItemPurchased, EventHookMode_Post);
  WeaponOffset = FindSendPropOffs("CBaseCombatWeapon", "m_hOwnerEntity");
}

/*DeactivateInfiniteCash()
{
  UnhookEvent("item_purchase", Event_OnItemPurchased, EventHookMode_Post);
}*/
