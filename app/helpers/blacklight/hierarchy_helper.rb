module Blacklight::HierarchyHelper

def is_hierarchical?(field_name)
  (prefix,order) = field_name.split(/_/, 2)
  list = blacklight_config.facet_display[:hierarchy][prefix] and list.include?(order)
end

def facet_order(prefix)
  param_name = "#{prefix}_facet_order".to_sym
  params[param_name] || blacklight_config.facet_display[:hierarchy][prefix].first
end

def facet_after(prefix, order)
  orders = blacklight_config.facet_display[:hierarchy][prefix]
  orders[orders.index(order)+1] || orders.first
end

def hide_facet?(field_name)
  if is_hierarchical?(field_name)
    prefix = field_name.split(/_/).first
    field_name != "#{prefix}_#{facet_order(prefix)}"
  else
    false
  end
end

def rotate_facet_value(val, from, to)
  components = Hash[from.split(//).zip(val.split(/:/))]
  new_values = components.values_at(*(to.split(//)))
  while new_values.last.nil?
    new_values.pop
  end
  if new_values.include?(nil)
    nil
  else
    new_values.compact.join(':')
  end
end

def rotate_facet_params(prefix, from, to, p=params.dup)
  return p if from == to
  from_field = "#{prefix}_#{from}"
  to_field = "#{prefix}_#{to}"
  p[:f] = (p[:f] || {}).dup # the command above is not deep in rails3, !@#$!@#$
  p[:f][from_field] = (p[:f][from_field] || []).dup
  p[:f][to_field] = (p[:f][to_field] || []).dup
  p[:f][from_field].reject! { |v| p[:f][to_field] << rotate_facet_value(v, from, to); true }
  p[:f].delete(from_field)
  p[:f][to_field].compact!
  p[:f].delete(to_field) if p[:f][to_field].empty?
  p
end

def render_facet_rotate(field_name)
  if is_hierarchical?(field_name)
    (prefix,order) = field_name.split(/_/, 2)

    return if blacklight_config.facet_display[:hierarchy][prefix].length < 2

    new_order = facet_after(prefix,order)
    new_params = rotate_facet_params(prefix,order,new_order)
    new_params["#{prefix}_facet_order"] = new_order
    link_to image_tag('icons/rotate.png', :title => new_order.upcase).html_safe, new_params, :class => 'no-underline'
  end
end
# Putting bare HTML strings in a helper sucks. But in this case, with a
# lot of recursive tree-walking going on, it's an order of magnitude faster
# than either render(:partial) or content_tag
  def render_facet_hierarchy_item(field_name, data, key)

    item = data[:_]
    path = item.qvalue.to_s.split(":")
    level = path.length.to_s
    subset = data.reject { |k,v| ! k.is_a?(String) }

    li_class = subset.empty? ? 'h-leaf' : 'h-node'
    li_class = ''
    li = ul =''

    if item.nil?
      li = key
      #elsif facet_in_params?(field_name, item.qvalue)
      # li = render_selected_qfacet_value(field_name, item)
    else
      li = render_qfacet_value(field_name, item)
    end

    unless subset.empty?
      subul = subset.keys.sort.collect do |subkey|
        render_facet_hierarchy_item(field_name, subset[subkey], subkey)
      end.join('')
      ul = "<ul class='facet-hierarchy' style='display: block;'>#{subul}</ul>".html_safe
    end

    li_class = ''
    marginRight = 'margin-right:0px;'
    addHeader = ''
    if level.to_s == '1'
      marginRight = 'margin-right:60px;'
      # two lines below for collapsing
      #addHeader= '<h4 class="">' + item.qvalue + '</span><i class="icon-chevron"></i></h4>'
      #addHeader= '<h4 class="">' + item.qvalue + '<span>' + render_facet_count(item.hits) +  '</span><i class="icon-chevron"></i></h4>'
      addHeader= '<p class="hf">' + item.qvalue + '<span style="margin-left:-100px;float:right !important">' + item.hits.to_s + '</span><i class="icon-chevron" style="margin-right:-30px"></i></p>'

      li=''
    end

    %{<li class="#{li_class}" style="padding-right:0px;#{marginRight}">#{addHeader}#{li.html_safe}#{ul.html_safe}</li>}.html_safe
  end

# Putting bare HTML strings in a helper sucks. But in this case, with a
# lot of recursive tree-walking going on, it's an order of magnitude faster
# than either render(:partial) or content_tag
def render_facet_hierarchy_item_almost(field_name, data, key)

  item = data[:_]
  path = item.qvalue.to_s.split(":")
  level = path.length.to_s
  subset = data.reject { |k,v| ! k.is_a?(String) }

  #puts "path = " + path.to_s

  li_class = subset.empty? ? 'h-leaf' : 'h-node'
  li_class = ''
  li = ul =''

  if item.nil?
    li = key
    #elsif facet_in_params?(field_name, item.qvalue)
    # li = render_selected_qfacet_value(field_name, item)
  else
    li = render_qfacet_value(field_name, item)
  end

  unless subset.empty?
    subul = subset.keys.sort.collect do |subkey|
      #puts 'about to render iten partial subkey' + subkey
      render_facet_hierarchy_item(field_name, subset[subkey], subkey)
      %{<li>hi there</li>}
    end.join('')
    ul = "<ul class='facet-hierarchy' style='display: block;'>#{subul}</ul>".html_safe
    puts "ul = + subul: " + subul
  end

  li_class = ''
  marginRight = 'margin-right:0px;'
  addHeader = ''
  if level.to_s == '1'
    puts "LEVEL 1"
    marginRight = 'margin-right:60px;'
    # two lines below for collapsing
    #addHeader= '<h4 class="">' + item.qvalue + '</span><i class="icon-chevron"></i></h4>'
    #addHeader= '<h4 class="">' + item.qvalue + '<span>' + render_facet_count(item.hits) +  '</span><i class="icon-chevron"></i></h4>'
    addHeader= '<p class="hf">' + item.qvalue + '<span>'+ render_facet_count(item.hits) +   '</span> <i class="icon-chevron"></i></p>'
    li=''
  end

  %{<li class="#{li_class}" style="padding-right:0px;#{marginRight}">#{addHeader}#{li.html_safe}#{ul.html_safe}</li>}.html_safe
  %{<li class="#{li_class}" style="padding-right:0px;#{marginRight}">#{li.html_safe}#{ul.html_safe}</li>}.html_safe
  puts '%{<li class="#{li_class}" style="padding-right:0px;#{marginRight}">#{addHeader}#{li.html_safe}#{ul.html_safe}</li>}.html_safe'
end


def render_hierarchy(field)
  field = field::field
  #field = "decoration_facet" # 1) extrtact t:his from the new field
  puts "In hierBL: render_hierarchy: field = " + field.to_s
  #prefix = field.field.split(/_/).first
  prefix = field.split(/_/).first
  puts "In hierBL: render_hierarchy: prefix = " + prefix

  #tree = facet_tree(prefix)[field.field]
  tree = facet_tree(prefix)[field]
  puts "In hierBL: render_hierarchy: about to sort tree"
  puts 'keys =  ' + tree.keys.to_s

  tree.keys.sort.collect do |key|
    #render_facet_hierarchy_item(field.field, tree[key], key)
    #puts 'about to render item: field: ' + field + "  key: " + key

    render_facet_hierarchy_item(field, tree[key], key)

    #puts 'just rendered item'
  end.join("\n").html_safe

end

def render_qfacet_value(facet_solr_field, item, options ={})
  #(link_to_unless(options[:suppress_link], item.value, add_facet_params(facet_solr_field, item.qvalue), :class=>"facet_select label") + " " + render_facet_count(item.hits)).html_safe
  (link_to_unless(options[:suppress_link], item.value, add_facet_params(facet_solr_field, item.qvalue), :class=>"labelnonesuch")       + " " + render_facet_count(item.hits)).html_safe


end

# Standard display of a SELECTED facet value, no link, special span
# with class, and 'remove' button.
def render_selected_qfacet_value(facet_solr_field, item)
  content_tag(:span, render_qfacet_value(facet_solr_field, item, :suppress_link => true), :class => "selected label") +
      link_to("[remove]", remove_facet_params(facet_solr_field, item.qvalue, params), :class=>"remove")
end

HierarchicalFacetItem = Struct.new :qvalue, :value, :hits
def facet_tree(prefix)
  @facet_tree ||= {}
  if @facet_tree[prefix].nil?
    @facet_tree[prefix] = {}

    blacklight_config.facet_display[:hierarchy][prefix].each { |key|

      puts "tree:prefix = "+prefix
      puts "tree:key= " + key


      facet_field = [prefix,key].compact.join('_')
      @facet_tree[prefix][facet_field] ||= {}
      data = @response.facet_by_field_name(facet_field)

      next if data.nil?

      data.items.each { |facet_item|
        #puts "treeloop:facet_item = " + facet_item.to_s
        #puts "treeloop:facet_item.value = " + facet_item.value
        #puts "treeloop:facet_item.value.split = " + facet_item.value.split(/\s*:\s*/).last
        #puts "treeloop:facet_item.hits = " + facet_item.hits.to_s
        #puts ''
        path = facet_item.value.split(/\s*:\s*/)
        #puts "treeloop: path: " + path.to_s
        loc = @facet_tree[prefix][facet_field]
        #puts "treeloop: loc; " + loc.to_s
        while path.length > 0
          loc = loc[path.shift] ||= {}
          #puts "loc = " + loc.to_s
        end
        loc[:_] = HierarchicalFacetItem.new(facet_item.value, facet_item.value.split(/\s*:\s*/).last, facet_item.hits)
      }
    }
  end
  puts "tree: keys = " + @facet_tree[prefix].keys.to_s
  @facet_tree[prefix]
end

end
