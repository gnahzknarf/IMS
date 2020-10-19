function sentry
    return boolean
is
    l_x01      varchar2(32767);
    l_jwt      apex_jwt.t_token;
    l_jwt_user varchar2(255);
    l_jwt_elts apex_t_varchar2;
begin
    --
    -- parse JWT payload in X01
    --
    l_x01 := v('APP_AJAX_X01');
    apex_debug.trace('X01=%s', l_x01);
    if l_x01 like '%.%.%' then
        begin
            l_jwt := apex_jwt.decode (
                         p_value         => l_x01,
                         p_signature_key => sys.utl_raw.cast_to_raw('XVTFBXHqwG7QqOihDo5YvPaHu87KZOIr') );
            apex_debug.trace('JWT payload=%s', l_jwt.payload);
            apex_jwt.validate (
                 p_token => l_jwt,
                 p_iss   => 'other_app',
                 p_aud   => 'CIMS' );
            apex_debug.trace('...validated');
            apex_json.parse (
                 p_source => l_jwt.payload );
            l_jwt_user := apex_json.get_varchar2('sub');
        exception when others then
            apex_debug.trace('...error: %s', sqlerrm);
        end;
    end if;
    --
    -- if not logged in yet:
    -- - log in with JWT user if JWT given
    -- - or trigger custom invalid session/login flow
    --
    if apex_authentication.is_public_user then
        if l_jwt_user is not null then
            apex_authentication.post_login (
                p_username => l_jwt_user );
        else
            return false;
        end if;
    elsif apex_application.g_user <> l_jwt_user then
        apex_debug.trace('...login user %s does not match JWT user %s',
            apex_application.g_user,
            l_jwt_user );
        return false;
    end if;
    --
    -- if JWT given, assign additional parameters to items
    --
    if l_jwt_user is not null then
        l_jwt_elts := apex_json.get_members('.');
        for i in 1 .. l_jwt_elts.count loop
            if l_jwt_elts(i) like 'P%' then
                apex_debug.trace('...setting %s', l_jwt_elts(i));
                apex_util.set_session_state (
                    p_name  => l_jwt_elts(i),
                    p_value => apex_json.get_varchar2(l_jwt_elts(i)) );
            end if;
        end loop;
    end if;
    return true;
end sentry;