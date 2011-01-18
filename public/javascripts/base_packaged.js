jQuery(function($){var csrf_token=$('meta[name=csrf-token]').attr('content'),csrf_param=$('meta[name=csrf-param]').attr('content');$.fn.extend({triggerAndReturn:function(name,data){var event=new $.Event(name);this.trigger(event,data);return event.result!==false;},callRemote:function(){var el=this,method=el.attr('method')||el.attr('data-method')||'GET',url=el.attr('action')||el.attr('href'),dataType=el.attr('data-type')||($.ajaxSettings&&$.ajaxSettings.dataType);if(url===undefined){throw"No URL specified for remote call (action or href must be present).";}else{var $this=$(this),data=el.is('form')?el.serializeArray():[];$.ajax({url:url,data:data,dataType:dataType,type:method.toUpperCase(),beforeSend:function(xhr){xhr.setRequestHeader("Accept","text/javascript");if($this.triggerHandler('ajax:beforeSend')===false){return false;}},success:function(data,status,xhr){el.trigger('ajax:success',[data,status,xhr]);},complete:function(xhr){el.trigger('ajax:complete',xhr);},error:function(xhr,status,error){el.trigger('ajax:error',[xhr,status,error]);}});}}});$('body').delegate('a[data-confirm], button[data-confirm], input[data-confirm]','click.rails',function(){var el=$(this);if(el.triggerAndReturn('confirm')){if(!confirm(el.attr('data-confirm'))){return false;}}});$('form[data-remote]').live('submit.rails',function(e){$(this).callRemote();e.preventDefault();});$('a[data-remote],input[data-remote]').live('click.rails',function(e){$(this).callRemote();e.preventDefault();});$('a[data-method]:not([data-remote])').live('click.rails',function(e){var link=$(this),href=link.attr('href'),method=link.attr('data-method'),form=$('<form method="post" action="'+href+'"></form>'),metadata_input='<input name="_method" value="'+method+'" type="hidden" />';if(csrf_param!==undefined&&csrf_token!==undefined){metadata_input+='<input name="'+csrf_param+'" value="'+csrf_token+'" type="hidden" />';}
form.hide().append(metadata_input).appendTo('body');e.preventDefault();form.submit();});var disable_with_input_selector='input[data-disable-with]',disable_with_form_remote_selector='form[data-remote]:has('+disable_with_input_selector+')',disable_with_form_not_remote_selector='form:not([data-remote]):has('+disable_with_input_selector+')';var disable_with_input_function=function(){$(this).find(disable_with_input_selector).each(function(){var input=$(this);input.data('enable-with',input.val()).attr('value',input.attr('data-disable-with')).attr('disabled','disabled');});};$(disable_with_form_remote_selector).live('ajax:before.rails',disable_with_input_function);$(disable_with_form_not_remote_selector).live('submit.rails',disable_with_input_function);$(disable_with_form_remote_selector).live('ajax:complete.rails',function(){$(this).find(disable_with_input_selector).each(function(){var input=$(this);input.removeAttr('disabled').val(input.data('enable-with'));});});var jqueryVersion=$().jquery;if(!((jqueryVersion==='1.4.3')||(jqueryVersion==='1.4.4'))){alert('This rails.js does not support the jQuery version you are using. Please read documentation.');}});(function($){var trailing_whitespace=true;$.fn.truncate=function(options){var opts=$.extend({},$.fn.truncate.defaults,options);$(this).each(function(){var content_length=$.trim(squeeze($(this).text())).length;if(content_length<=opts.max_length)
return;var actual_max_length=opts.max_length-opts.more.length-3;var truncated_node=recursivelyTruncate(this,actual_max_length);var full_node=$(this).hide();truncated_node.insertAfter(full_node);findNodeForMore(truncated_node).append(' (<a href="#show more content">'+opts.more+'</a>)');findNodeForLess(full_node).append(' (<a href="#show less content">'+opts.less+'</a>)');truncated_node.find('a:last').click(function(){truncated_node.hide();full_node.show();return false;});full_node.find('a:last').click(function(){truncated_node.show();full_node.hide();return false;});});}
$.fn.truncate.defaults={max_length:100,more:'...more',less:'less'};function recursivelyTruncate(node,max_length){return(node.nodeType==3)?truncateText(node,max_length):truncateNode(node,max_length);}
function truncateNode(node,max_length){var node=$(node);var new_node=node.clone().empty();var truncatedChild;node.contents().each(function(){var remaining_length=max_length-new_node.text().length;if(remaining_length==0)return;truncatedChild=recursivelyTruncate(this,remaining_length);if(truncatedChild)new_node.append(truncatedChild);});return new_node;}
function truncateText(node,max_length){var text=squeeze(node.data);if(trailing_whitespace)
text=text.replace(/^ /,'');trailing_whitespace=!!text.match(/ $/);var text=text.slice(0,max_length);text=$('<div/>').text(text).html();return text;}
function squeeze(string){return string.replace(/\s+/g,' ');}
function findNodeForMore(node){var $node=$(node);var last_child=$node.children(":last");if(!last_child)return node;var display=last_child.css('display');if(!display||display=='inline')return $node;return findNodeForMore(last_child);};function findNodeForLess(node){var $node=$(node);var last_child=$node.children(":last");if(last_child&&last_child.is('p'))return last_child;return node;};})(jQuery);jQuery.fn.collapseDiv=function(){return this.each(function(){var jQueryCollapse=jQuery(this);var jQueryroots=jQueryCollapse.find('div');jQueryCollapse.addClass('my-collapse');jQueryCollapse.find('div').hide();jQueryCollapse.find('h2').prepend('<span class="expand" />');jQueryCollapse.addClass('expanded');jQuery('span.expand').toggle(function(){jQuery(this).toggleClass('contract').parent().next('div').slideDown();jQuery(this).parent().toggleClass('expanded');},function(){jQuery(this).toggleClass('contract').parent().next('div').slideUp();jQuery(this).parent().toggleClass('expanded');});});};jQuery.fn.quickTree=function(){return this.each(function(){var jQuerytree=jQuery(this);var jQueryroots=jQuerytree.find('li');jQuerytree.addClass('tree');jQuerytree.find('ul').hide();jQueryroots.each(function(){if(jQuery(this).children('ul').length>0){jQuery(this).addClass('root').contents(':first').wrap('<span class="expand" />');jQuery(this).parent().addClass('expanded');}});jQuery('span.expand').toggle(function(){jQuery(this).toggleClass('contract').nextAll('ul').slideDown();jQuery(this).parent().toggleClass('expanded');},function(){jQuery(this).toggleClass('contract').nextAll('ul').slideUp();jQuery(this).parent().toggleClass('expanded');});});};jQuery(document).ready(function(){function geo_decode(){var email=jQuery('.person-email').get(0);if((email!=undefined)){email_name=email.innerHTML.split(/ /)[0]
email_domain=email.innerHTML.split(/ /)[2]
email_string=[email_name,email_domain].join('@');jQuery(email).replaceWith("<a id='email' href='mailto:"+email_string+"'>"+email_string+"</a>");}};jQuery('.truncate').truncate({max_length:500});geo_decode();jQuery('.quickTree').quickTree();jQuery('.collapsable').collapseDiv();jQuery('.quickTree').prepend("<a href='#' class='expand_all'>[Expand All]</a>")
jQuery('.expand_all').toggle(function(){jQuery('span.expand:not(.contract)').trigger('click');jQuery(this).text('[Collapse All]');},function(){jQuery('span.expand.contract').trigger('click');jQuery(this).text('[Expand All]');});jQuery('.deleter').live('click',function(e){e.preventDefault();path=jQuery(this).attr('href');jQuery(this).parent().hide('slow');jQuery.ajax({type:'DELETE',url:path});});});function remove_fields(link){jQuery(link).prev("input[type=hidden]").val("1");jQuery(link).parent().parent(".inputs").first().hide();}
function add_fields(link,association,content){var new_id=new Date().getTime();var regexp=new RegExp("new_"+association,"g")
jQuery(link).prev().append(content.replace(regexp,new_id));}