#include <amxmodx>
#include <fakemeta>
#include <sockets>

new g_sock, g_enabled, g_port, g_tick_ms, g_log;
new g_host[32];

public plugin_init() {
    register_plugin("AI Bridge", "0.1", "zombie_ai_dev");

    // Cvars
    bind_pcvar_num( create_cvar("aibridge_enabled","1"), g_enabled );
    bind_pcvar_string( create_cvar("aibridge_host","127.0.0.1"), g_host, charsmax(g_host) );
    bind_pcvar_num( create_cvar("aibridge_port","31337"), g_port );
    bind_pcvar_num( create_cvar("aibridge_tick_ms","150"), g_tick_ms );
    bind_pcvar_num( create_cvar("aibridge_log","1"), g_log );

    // Open non-blocking UDP socket
    g_sock = socket_open(SOCKET_UDP, g_host, g_port, SOCKET_NONBLOCKING);

    set_task(float(g_tick_ms) / 1000.0, "tick_send_state", .flags="b");
    set_task(0.05, "tick_recv_cmds", .flags="b");
}

public plugin_end() {
    if (g_sock) socket_close(g_sock);
}

public tick_send_state() {
    if (!g_enabled || !g_sock) return;

    new buffer[1200], len = 0;
    new mapname[32]; get_mapname(mapname, charsmax(mapname));
    len += formatex(buffer[len], charsmax(buffer)-len, "{\"v\":0,\"t\":%d,\"map\":\"%s\",\"pl\":[", get_systime(), mapname);

    new maxp = get_maxplayers();
    new first = 1;
    for (new id = 1; id <= maxp; id++) {
        if (!is_user_connected(id)) continue;
        new is_alive = is_user_alive(id);
        new is_bot = is_user_bot(id);
        new team = get_user_team(id); // 1=T, 2=CT in vanilla
        new Float:origin[3]; pev(id, pev_origin, origin);
        if (!first) len += formatex(buffer[len], charsmax(buffer)-len, ",");
        first = 0;
        len += formatex(buffer[len], charsmax(buffer)-len,
            "{\"id\":%d,\"t\":%d,\"b\":%d,\"a\":%d,\"x\":%d,\"y\":%d,\"z\":%d}",
            id, team, is_bot, is_alive, floatround(origin[0]), floatround(origin[1]), floatround(origin[2]));
    }
    len += formatex(buffer[len], charsmax(buffer)-len, "]}" );

    socket_send(g_sock, buffer, len);

    if (g_log) server_print("[ai_bridge] sent snapshot (%d bytes)", len);
}

public tick_recv_cmds() {
    if (!g_enabled || !g_sock) return;

    new recvbuf[1200], fromip[32], fromport;
    new r = socket_recvfrom(g_sock, recvbuf, charsmax(recvbuf), fromip, fromport);
    if (r <= 0) return;

    // Expect a JSON of shape: {"cmds":[{"id":12,"goal_wp":134,"agg":0.9,"mode":"flank"}, ...]}
    // Minimal parse: find occurrences of "id": and "goal_wp":
    new i = 0;
    while ((i = containi(recvbuf[i], "\"id\":")) != -1) {
        i += 5; // move after "id":
        new bid = str_to_num(recvbuf[i]);  // crude; relies on well-formed JSON

        new j = containi(recvbuf[i], "\"goal_wp\":");
        if (j == -1) break;
        j += 10;
        new goal = str_to_num(recvbuf[j]);

        // TODO: if your YaPB exposes natives, call them here (preferred).
        // Fallback: issue a console command to steer a specific bot (version-dependent).
        // Example placeholder (replace with real YaPB command on your build):
        // server_cmd("yb aim 1"); // demo: turn some yb behavior on
        // server_cmd("yb_forcegoal %d %d", bid, goal); // imaginary; replace with actual

        if (g_log) server_print("[ai_bridge] cmd -> bot %d to wp %d", bid, goal);
    }
}