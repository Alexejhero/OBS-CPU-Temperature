obs = obslua

local enabled = false
local exe_path = ""
local source_name = ""

function script_description()
    return "This script runs a specified executable when the plugin starts and kills it when the plugin stops."
end

function script_load(settings)
    enabled = obs.obs_data_get_bool(settings, "enabled")
    exe_path = obs.obs_data_get_string(settings, "exe_path")
    if enabled and exe_path ~= "" then
        start_exe()
    end
end

function script_unload()
    if enabled and exe_path ~= "" then
        stop_exe()
    end
end

function script_properties()
    local props = obs.obs_properties_create()
    obs.obs_properties_add_bool(props, "enabled", "Enabled")
    obs.obs_properties_add_path(props, "exe_path", "Executable Path", obs.OBS_PATH_FILE, "Executable files (*.exe);;All files (*.*)", nil)

    local source = obs.obs_properties_add_list(props, 'source', 'Source', obs.OBS_COMBO_TYPE_EDITABLE, obs.OBS_COMBO_FORMAT_STRING)
    for _, name in ipairs(get_source_names()) do
      obs.obs_property_list_add_string(source, name, name)
    end

    return props
end

function script_update(settings)
    source_name = obs.obs_data_get_string(settings, "source")

    local new_enabled = obs.obs_data_get_bool(settings, "enabled")
    local new_exe_path = obs.obs_data_get_string(settings, "exe_path")

    if new_enabled ~= enabled or new_exe_path ~= exe_path then
        if enabled then
            stop_exe()
        end
        enabled = new_enabled
        exe_path = new_exe_path
        if enabled and exe_path ~= "" then
            start_exe()
        end
    end
end

function start_exe()
    os.execute('start "" /B "' .. exe_path .. '"')
    local source = obs.obs_get_source_by_name(source_name)
    if source then
        obs.obs_source_set_enabled(source, true)
        obs.obs_source_release(source)
    end
end

function stop_exe()
    local exe_name = exe_path:match("([^\\/]+)$")
    if exe_name then
        os.execute('taskkill /IM "' .. exe_name .. '" /F')
        print('taskkill /IM "' .. exe_name .. '" /F')
    end
    local source = obs.obs_get_source_by_name(source_name)
    if source then
        obs.obs_source_set_enabled(source, false)
        obs.obs_source_release(source)
    end
end

function get_source_names()
    local sources = obs.obs_enum_sources()
    local source_names = {}
    if sources then
        for _, source in ipairs(sources) do
            local source_id = obs.obs_source_get_id(source)
            if string.find(source_id, "text_gdiplus") or string.find(source_id, "text_ft2") then
                table.insert(source_names, obs.obs_source_get_name(source))
            end
        end
    end
    obs.source_list_release(sources)
    table.sort(source_names, function(a, b)
        return string.lower(a) < string.lower(b)
    end)
    return source_names
end
