#!/bin/bash

#=================================================
# RETRIEVE ARGUMENTS FROM THE MANIFEST
#=================================================

# Transfer the main SSO domain to the App:
ynh_current_host=$(cat /etc/yunohost/current_host)
__YNH_CURRENT_HOST__=${ynh_current_host}

#=================================================
# ARGUMENTS FROM CONFIG PANEL
#=================================================

# 'debug_enabled' -> '__DEBUG_ENABLED__' -> settings.DEBUG
debug_enabled="0" # "1" or "0" string

# 'log_level' -> '__LOG_LEVEL__' -> settings.LOG_LEVEL
log_level="WARNING"

#=================================================
# SET CONSTANTS
#=================================================

# e.g.: point pip cache to: /var/www/$app/.cache/
XDG_CACHE_HOME="$install_dir/.cache/"

log_path=/var/log/$app
log_file="${log_path}/${app}.log"

#=================================================
# HELPERS
#=================================================

myynh_setup_python_venv() {
    # Always recreate everything fresh with current python version
    ynh_secure_remove "$install_dir/venv"

    chown -R "$app:$app" "$install_dir"

    # Skip pip because of: https://github.com/YunoHost/issues/issues/1960
    ynh_exec_as "$app" python3 -m venv --without-pip "$install_dir/venv"

    ynh_exec_as $app $install_dir/venv/bin/python3 -m ensurepip
    # using --no-cache-dir option because user doesn't have permission to write on cache directory (don't know if it's on purpose or not)
    ynh_exec_as $app $install_dir/venv/bin/pip3 install --no-cache-dir --upgrade wheel pip setuptools
    ynh_exec_as $app $install_dir/venv/bin/pip3 install --no-cache-dir -r "$install_dir/requirements.txt"
}

myynh_setup_log_file() {
    (
        set -x

        mkdir -p "$(dirname "$log_file")"
        touch "$log_file"

        chown -c -R $app:$app "$log_path"
        chmod -c o-rwx "$log_path"
    )
}

myynh_fix_file_permissions() {
    (
        set -x

        # /home/yunohost.app/$app/
        chown -c -R "$app:" "$data_dir"
        chmod -c o-rwx "$data_dir"

        # /var/www/$app/
        chown -c -R "$app:" "$install_dir"
        chmod -c o-rwx "$install_dir"
    )
}
