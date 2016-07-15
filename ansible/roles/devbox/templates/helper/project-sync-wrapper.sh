#!/usr/bin/env bash


{% for helper in item.helper %}
function {{ helper.name }} {
    (cd / && {{ helper.command }})
}
{% endfor %}

# run script
if [ `type -t $1`"" == 'function' ]; then
    $1
else
    echo -e "
    \e[91m{{ item.name }}\e[0m - helper script

    USAGE:

{% for helper in item.helper %}
    \e[0;32m{{ helper.name }}\e[0m
    {{ helper.info | default('') }}

{% endfor %}

    "
fi
