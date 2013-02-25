/*global console*/

$(document).ready(function(){
    var $area = $('textarea.editor');
    var $v = window.v = $area.VimArea();
    $v.set("tabchar", "    ");
    $v.onSave = function(){
        $('form').submit();
    };

    // Textarea resizing
    function resize(){
        var v_overflow = $('body').outerHeight(true) - $(window).height();
        var height = $area.height();
        var newheight = $area.height() - v_overflow;
        $area.height(newheight);
    }

    $(window).on("resize", function(){ resize(); });

    resize();
    $area.trigger('focus');
});
