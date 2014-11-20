(function($) {
    Blacklight.do_hierarchical_facet_expand_contract_behavior = function() {
        $( Blacklight.do_hierarchical_facet_expand_contract_behavior.selector ).each (
            Blacklight.hierarchical_facet_expand_contract
        );
    }
    Blacklight.do_hierarchical_facet_expand_contract_behavior.selector = '.hf';
    //Blacklight.do_hierarchical_facet_expand_contract_behavior.selector = 'h4';

    Blacklight.hierarchical_facet_expand_contract = function() {
        var f_content = $(this);
        $(f_content).prev('.hf').addClass('twiddle');
        //$(f_content).prev('h4').addClass('twiddle');

        $(this).next("ul").each(function(){
            //if($('span.selected', this).length == 0){
                $(this).hide();
            //} //else {
            //alert("about to show()")
            //$(this).show();
            //f_content.addClass('twiddle-open');
            //}
        });

        // Attach the toggle behavior to the h4 tag
        $('.hf', f_content.parent()).click(function(){
        //$('h4', f_content.parent()).click(function(){
            //alert("in user interaction")
            // toggle the content
            $(this).toggleClass('twiddle-open');
            $(this).next("ul").slideToggle();
            //$(this).next().next().slideToggle();
        });
    };
    $(document).ready(function() {
        //alert("ready function")
        Blacklight.do_hierarchical_facet_expand_contract_behavior();
    });
})(jQuery);
