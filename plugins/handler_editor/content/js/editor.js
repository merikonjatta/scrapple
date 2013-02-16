$(document).ready(function(){
    function log(expr){
        console.log(expr + ": " + eval(expr));
    }

    // Textarea resizing
    function resize(){
        var v_overflow = $('body').outerHeight(true) - $(window).height();
        var height = $('textarea').height();
        var newheight = $('textarea').height() - v_overflow;
        $('textarea').height(newheight);
    }

    resize();

    $(window).on("resize", function(){ resize(); });
    //$('textarea').on("click", function(){ resize(); });

});
