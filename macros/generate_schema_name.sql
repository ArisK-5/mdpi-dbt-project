{% macro generate_schema_name(custom_schema_name, node) %}

    {# Default schema from profiles.yml target #}
    {% set default_schema = target.schema %}

    {# Seeds always go into the specified custom schema (e.g., raw) #}
    {% if node.resource_type == 'seed' %}
        {{ custom_schema_name | trim }}

    {# Models with no custom schema use the default target schema #}
    {% elif custom_schema_name is none %}
        {{ default_schema }}

    {# Models with a custom schema use it directly in all environments #}
    {% else %}
        {{ custom_schema_name | trim }}
    {% endif %}

{% endmacro %}
