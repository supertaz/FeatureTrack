$(function() {

    // if the function argument is given to overlay,
    // it is assumed to be the onBeforeLoad event listener
    $("#container a[rel]").overlay({

        expose: 'darkgrey',
        effect: 'apple',

        onBeforeLoad: function() {

            // grab wrapper element inside content
            var wrap = this.getContent().find(".contentWrap");

            // load the page specified in the trigger
            wrap.load(this.getTrigger().attr("href"));
        }

    });

    // scroll to targetable anchors that have an offset

    $("a[rel='scrollTo']").click(function(event){
        // skip the default action
        event.preventDefault();

        // get the top of the target
        var target = $('#' + this.href.split("#")[1]).offset();

        // subtract 87 pixels from the top to handle the fixed header
        var scrollLoc = target.top - 102;

        // scroll the visible area to reveal the target
        $('html, body').animate({scrollTop:scrollLoc}, 500);
    });

    var acceptedVisible = true;
    $("a[rel='toggle_accepted_stories']").click(function(event){
        event.preventDefault();
        if (acceptedVisible)
        {
            $(".accepted").hide();
            acceptedVisible = false;
        }
        else
        {
            $(".accepted").show();
            acceptedVisible = true;
        }
    })
});
