{% for item in site.sidebar-menu %}
  {% if item.type == 'categories' %}
    <li class="menu-category">{{ item.name }}</li>
    {% for category in item.children %}
      {% if category.type == 'categories' %}
        <li class="menu-category-sub">{{ category.name }}</li>
        {% for child in category.children %}
          <li><a href="{{ url_for(child.path) }}">{{ child.name }}</a></li>
        {% endfor %}
      {% else %}
        <li><a href="{{ url_for(category.path) }}">{{ category.name }}</a></li>
      {% endif %}
    {% endfor %}
  {% else %}
    <li><a href="{{ url_for(item.path) }}">{{ item.name }}</a></li>
  {% endif %}
{% endfor %}

{% for category in site.categories %}
{% if category.layout != nil %}
<li class="menu-item{% if page.category == category.title %} active{% endif %}">
  <a href="{{ category.url }}">{{ category.title }}</a>
  <ul class="sub-menu">
    {% for subcategory in category.categories %}
    {% if subcategory.layout != nil %}
    <li class="menu-item{% if page.subcategory == subcategory.title %} active{% endif %}">
      <a href="{{ subcategory.url }}">{{ subcategory.title }}</a>
    </li>
    {% endif %}
    {% endfor %}
  </ul>
</li>
{% endif %}
{% endfor %}
