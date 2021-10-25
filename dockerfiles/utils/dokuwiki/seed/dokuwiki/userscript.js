jQuery(function() {
    var $toc = jQuery('#dw__toc .toggle');
    if($toc.length) {
        $toc[0].setState(-1);

        jQuery('#dw__toc').show();
    }
});
