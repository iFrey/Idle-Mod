#pragma semicolon 1
#include <sourcemod>
#include <cstrike>
#include <sdktools_functions>

#define PLUGIN_VERSION "0.1.0"

new Handle:cv_h_instantrespawn = INVALID_HANDLE;
new cv_instantrespawn;
new Float:respawnctpos[36][3];
new Float:respawntpos[36][3];

public Plugin:myinfo =
{
  name = "[CS:GO] Idle Mod: Instant Respawn",
  author = "iFrey",
  description = "Instant respawn of Idle Mod",
  version = PLUGIN_VERSION,
  url = "In Progress"
}

public OnPluginStart()
{
  /*cv_h_instantrespawn = CreateConVar("im_intantrespawn", "1", "(0 = Disabled, 1 = Enabled)", FCVAR_NONE, true, 0.0, true, 1.0);
  HookConVarChange(cv_h_instantrespawn, OnCVarChange);
  cv_instantrespawn = GetConVarInt(cv_h_instantrespawn);

  if (cv_instantrespawn)*/ ActivateInstantRespawn();
  /*new Float:FirstCTPos[3]={200.0, 705.0, 64.0};
  new Float:FirstTPos[3]={200.0, -705.0, 64.0};
  //CT respawn positions
  for (new i=0; i<36;i++)
  {
    //rows
    for(new r=0;r<4;r++)
    {
      //colums
      for (new c=0;c<9;c++)
      {
        respawnctpos[i][0]=FirstCTPos[0]-(50*c);
        respawnctpos[i][1]=FirstCTPos[1]-(100*r);
        respawnctpos[i][2]=FirstCTPos[2];
      }
    }
  }
  //T respawn positions
  for (new i=0; i<36;i++)
  {
    //rows
    for(new r=0;r<4;r++)
    {
      //colums
      for (new c=0;c<9;c++)
      {
        respawntpos[i][0]=FirstTPos[0]-(50*c);
        respawntpos[i][1]=FirstTPos[1]+(100*r);
        respawntpos[i][2]=FirstTPos[2];
      }
    }
  }*/

}

/*public OnCVarChange(Handle:cvar, const String:oldvalue[], const String:newvalue[])
{
  if(cvar == cv_h_instantrespawn)
  {
    cv_instantrespawn = StringToInt(newvalue);
    if (cv_instantrespawn) ActivateInstantRespawn();
    else DeactivateInstantRespawn();
  }
}*/


public Action:Event_OnPlayerDeath(Handle:event, const String:name[], bool:dontBroadcast)
{
  new client = GetClientOfUserId(GetEventInt(event, "userid"));
  new team = GetClientTeam(client);
  if (IsClientInGame(client) && (team == CS_TEAM_T || team == CS_TEAM_CT))
  {
    CreateTimer(0.5, Respawn, client, TIMER_FLAG_NO_MAPCHANGE);
  }
  return Plugin_Continue;
}

public Action:Respawn(Handle:Timer, any:client)
{
  CS_RespawnPlayer(client);
}

/*public Action:Event_OnPlayerSpawned(Handle:event, const String:name[], bool:dontBroadcast)
{
  new client = GetClientOfUserId(GetEventInt(event, "userid"));
  new team = GetClientTeam(client);
  if (IsClientInGame(client) && IsRealPlayer(client))
  {
    if (team == CS_TEAM_T)
    {
      PrintToServer("client %d asginado el respawn x %f y %f z %f",client,respawntpos[client][0],respawntpos[client][1],respawntpos[client][2]);
      TeleportEntity(client, respawntpos[RoundToCeil(client/2)-1], NULL_VECTOR, NULL_VECTOR);
    }
    else if(team == CS_TEAM_CT)
  {
    PrintToServer("client %d asginado el respawn x %f y %f z %f",client,respawnctpos[client][0],respawnctpos[client][1],respawnctpos[client][2]);
    TeleportEntity(client, respawnctpos[RoundToCeil(client/2)-1], NULL_VECTOR, NULL_VECTOR);
  }
  }
  return Plugin_Stop;
}*/

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

ActivateInstantRespawn()
{
  HookEvent("player_death", Event_OnPlayerDeath, EventHookMode_Pre);
  //HookEvent("player_spawned", Event_OnPlayerSpawned, EventHookMode_Post);
}

/*DeactivateInstantRespawn()
{
  UnhookEvent("player_death", Event_OnPlayerDeath, EventHookMode_Pre);
  UnhookEvent("player_spawned", Event_OnPlayerSpawned, EventHookMode_Post);

}*/
