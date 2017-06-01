#pragma semicolon 1
#include <sourcemod>
#include <cstrike>
#include <sdktools_functions>

#define PLUGIN_VERSION "0.1.0"

new String:sql_createconnections[] =
          "CREATE TABLE IF NOT EXISTS connections (steam_id TEXT NOT NULL,con_timestamp INTEGER NOT NULL,dis_timestamp INTEGER,time_connected INTEGER,client_ip TEXT,PRIMARY KEY('steam_id'));";

new String:sql_createtickets[] =
          "CREATE TABLE IF NOT EXISTS tickets (steam_id TEXT NOT NULL,ticket_id INTEGER NOT NULL AUTO_INCREMENT,PRIMARY KEY('ticket_id'));";

new Handle:cv_h_stattrack = INVALID_HANDLE;
new cv_stattrack;

new Handle:db = INVALID_HANDLE;

public Plugin:myinfo =
{
  name = "[CS:GO] Idle Mod: Stats Tracking",
  author = "iFrey",
  description = "Stats Tracking of Idle Mod",
  version = PLUGIN_VERSION,
  url = "In Progress"
}

public OnPluginStart()
{

  InitializeDB();

  /*cv_h_stattrack = CreateConVar("im_stattrack", "1", "(0 = Disabled, 1 = Enabled)", FCVAR_NONE, true, 0.0, true, 1.0);
  HookConVarChange(cv_h_stattrack, OnCVarChange);
  cv_stattrack = GetConVarInt(cv_h_stattrack);*/

  /*if (cv_stattrack)*/	ActivateStatTrack();
}



/*public OnCVarChange(Handle:cvar, const String:oldvalue[], const String:newvalue[])
{
  if(cvar == cv_h_stattrack)
  {
    cv_stattrack = StringToInt(newvalue);
    if (cv_stattrack) ActivateStatTrack();
    else DeactivateStatTrack();
  }
}*/



public Action:Event_OnPlayerConnected(Handle:event, const String:name[], bool:dontBroadcast)
{
  decl String:steamId[20];
  decl String:buffer[200];
  decl String:ip[ 17 ]; // 17 is enough
  new client = GetClientOfUserId(GetEventInt(event, "userid"));

  if(client && IsClientConnected(client) && !IsFakeClient(client))
  {
    GetClientIP( client, ip, 16, 1 );
    GetClientAuthString(client, steamId, sizeof(steamId));

    Format(buffer, sizeof(buffer), "INSERT INTO connections(steam_id,con_timestamp,client_ip) VALUES ('%s', %i, %i)", steamId, GetTime(), ip);//IF NOT EXISTS
    SQL_TQuery(db, SQLErrorCheckCallback, buffer);
  }
  return Plugin_Continue;
}

public Action:Event_OnClientDisconnected(Handle:event, const String:name[], bool:dontBroadcast)
{
  new client = GetClientOfUserId(GetEventInt(event, "userid"));
  decl String:steamId[20];
  decl String:buffer[200];

  if(client && IsClientConnected(client) && !IsFakeClient(client))
  {
    GetClientAuthString(client, steamId, sizeof(steamId));

    Format(buffer, sizeof(buffer), "UPDATE connections SET dis_timestamp = %i time_conected =  %i - con_timestamp WHERE steam_id = '%s' AND con_timestamp = (SELECT MAX(con_timestamp) FROM connections WHERE steam_id = '%s')", GetTime(),GetTime(),steamId,steamId);
    SQL_TQuery(db, SQLErrorCheckCallback, buffer);
  }
  return Plugin_Continue;
}

// This is used during a threaded query that does not return data
public SQLErrorCheckCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
  if(!StrEqual("", error))
  {
    PrintToServer("Last Connect SQL Error: %s", error);
  }
}

public InitializeDB()
{
  new String:error[255];
  db = SQL_Connect("stattrack", false, error, sizeof(error));
  //db = SQL_ConnectEx(SQL_GetDriver("InnoDB"), "", "", "", "last_connect", error, sizeof(error), true, 0);
  //Si falla
  //db = SQL_DefConnect(error, sizeof(error))
  //o
  //db = SQL_DefConnect(error, sizeof(error))
  if(db == INVALID_HANDLE)
  {
    SetFailState(error);
  }
  SQL_LockDatabase(db);
  SQL_FastQuery(db, sql_createconnections);
  SQL_FastQuery(db, sql_createtickets);
  SQL_UnlockDatabase(db);
}

CreateTicket(client)
{
  decl String:steamId[20];
  decl String:buffer[200];

  if(client && IsClientConnected(client) && !IsFakeClient(client))
  {
    GetClientAuthString(client, steamId, sizeof(steamId));

    Format(buffer, sizeof(buffer), "INSERT INTO tickets VALUES ('%s')", steamId);
    SQL_TQuery(db, SQLErrorCheckCallback, buffer);
  }
}

CheckUserTickets(client)
{
  new String:query[100];
  Format(query, sizeof(query), "SELECT count(ticket_id) FROM tickets WHERE steam_id = %s" , client);

  SQL_LockDatabase(db);
  new Handle:hQuery = SQL_Query(db, query);
  if (hQuery == INVALID_HANDLE)
  {
    SQL_UnlockDatabase(db);
    return -1;
  }
  SQL_UnlockDatabase(db);

  PrintResults(hQuery,client);

  CloseHandle(hQuery);

  return 1;
}

PrintResults(Handle:query,client)
{
  /* Even if we have just one row, you must call SQL_FetchRow() first */
  new tickets;
  while (SQL_FetchRow(query))
  {
    SQL_FetchInt(query, 0, tickets);
    PrintToChat(client,"You have \"%i\" tickets.", tickets);
  }
}

public Action:OnClientCommand(client, args)
{
  new String:cmd[16];
  GetCmdArg(0, cmd, sizeof(cmd));	/* Get command name */

  if (StrEqual(cmd, "check_tickets"))
  {
    CheckUserTickets(client);
    return Plugin_Handled;
  }

  return Plugin_Continue;
}

public Action:Event_OnPlayerActivated(Handle:event, const String:name[], bool:dontBroadcast)
{
  new client = GetClientOfUserId(GetEventInt(event, "userid"));
  if (HasNoTickets(client)) CreateTicket(client);
  return Plugin_Continue;
}

bool:HasNoTickets(client)
{
  new String:query[100];
  new bool:isNull;
  Format(query, sizeof(query), "SELECT count(ticket_id) FROM tickets WHERE steam_id = %s" , client);

  SQL_LockDatabase(db);
  new Handle:hQuery = SQL_Query(db, query);
  if (hQuery == INVALID_HANDLE)
  {
    SQL_UnlockDatabase(db);
    return false;
  }
  SQL_UnlockDatabase(db);

  isNull = SQL_IsFieldNull(hQuery, 0);

  CloseHandle(hQuery);

  return isNull;
}

public Action:Timer_GiveTickets(Handle:Timer)
{
  for(new i = 1; i <= GetMaxClients() && IsRealPlayer(i); i++)
  {
    CreateTicket(i);
    PrintToChat(i, "You have been rewarded with 1 ticket more.");
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

ActivateStatTrack()
{
  HookEvent("player_activate", Event_OnPlayerActivated, EventHookMode_Post);
  CreateTimer(3.0, Timer_GiveTickets, _, TIMER_REPEAT);
}

/*DeactivateStatTrack()
{
  UnhookEvent("player_activate", Event_OnPlayerActivated, EventHookMode_Post);
}*/
