/*global console*/

$(document).ready(function(){
    var $area = $('textarea');
    var $v = window.v = $area.VimArea();
    $v.set("tabchar", "    ");

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


(function($){
    $.fn.VimArea = function() {
        if (this.is('textarea') || this.is('input[type="text"]')) {
            return new VimArea(this);
        } else {
            return this;
        }
    };


    // Constructor
    function VimArea($textarea) {
        this.$a = $textarea;
        this.regs = {};
        this.rCommandArgs = /(.+)\((.+)\)/;
        this.rInt         = /^-?[0-9]+$/;

        this.buildElements();
        this.toInsertMode();

        this.$a.on("keydown", $.proxy(this.keydown, this));
    }

    var Vproto = VimArea.prototype;

    Vproto.settings = {
        "tabchar": "\t"
    };

    /////////////////////////////////////////////////////////////////////////////
    // KEY PROCESSING                                                          //
    /////////////////////////////////////////////////////////////////////////////

    // Key mappings
    Vproto.keymap = {
        'insert': {
            "s191" : { "s191": { "s191": 'help' } },
            "c83"  : 'save',  // C-s
            "9"    : 'insertTab',   // TAB
            "8"    : 'backspace', // BS
            "27"   : 'toNormalMode', // ESC
            "c219" : 'toNormalMode' // C-[
        },
        'normal': {
            "73"  : 'toInsertMode', // i
            "s73" : 'movetoLineStart toInsertMode', // I
            "s65" : 'movetoLineEnd toInsertMode', // A
            "79"  : 'movetoLineEnd insertNewline toInsertMode', // o
            "s79" : 'movetoLineStart move(-1) insertNewline toInsertMode', // O
            "72"  : 'move(-1)', // h
            "74"  : 'moveVert(1)', // j
            "75"  : 'moveVert(-1)',   // k
            "76"  : 'move(1)',// l
            "8"   : 'move(-1)', // BS
            "32"  : 'move(1)', // Space
            "187" : 'movetoLineStart', // ^
            "s52" : 'movetoLineEnd',   // $
            "71"  : { "71" : 'movetoStart' },  // gg
            "s71" : 'movetoEnd', // G
            "68"  : { "68" : 'deleteLine' }, // dd
            "80"  : 'paste', // G
            "9"   : 'debug' // TAB
        }
    };

    Vproto.keyscope = null;
    Vproto.lastKeyEvents = null;

    // Get a keymap-expression for the keydown event.
    function keyexpr(e){
        // Ignore key events for ctrl and shift keys themselves
        if (e.which == 16 || e.which == 17) { return null; }
        var expr = "";
        if (e.shiftKey) { expr += "s"; }
        if (e.ctrlKey) { expr += "c"; }
        expr += e.which;
        console.log(expr);
        return expr;
    }

    var VprotoKeyResponder = {
        keyPreventDefault: function(){
            this.lastKeyEvent.preventDefault();
        },
    
        keydown: function(e){
            if (this.mode == "normal") { e.preventDefault(); }

            this.lastKeyEvent = e;
            this.auto_clear_keyscope(false);

            var new_keyscope = this.keyscope[keyexpr(e)];

            if (type(new_keyscope) == "Object") {
                this.keyscope = new_keyscope;
                this.auto_clear_keyscope(1000);
            } else if (type(new_keyscope) == "String") {
                this.run(new_keyscope);
                this.clear_keyscope();
            } else {
                this.clear_keyscope();
            }
        },

        clear_keyscope: function(){
            this.keyscope = this.keymap[this.mode];
            this.auto_clear_keyscope(false);
        },

        auto_clear_keyscope: function(msecs) {
            if (msecs === false && type(this.key_timeout_id) === "Number"){
                window.clearTimeout(this.key_timeout_id);
            } else {
                this.key_timeout_id = setTimeout($.proxy(this.clear_keyscope, this), msecs);
            }
        }
    };
    $.extend(Vproto, VprotoKeyResponder);


    /////////////////////////////////////////////////////////////////////////////
    // COMMANDS                                                                //
    /////////////////////////////////////////////////////////////////////////////

    // Execute a string-based chain of commands.
    // Commands should look like:
    // "moveToLineStart moveUp paste"
    // or
    // "move(1) deleteChar"
    // You can't nest commands in command arguments.
    Vproto.run = function(line){
        var commands = compact(line.split(" "));
        console.log(commands);
        var ret;

        for (var i in commands){
            var cmd = commands[i];
            var ma = cmd.match(this.rCommandArgs);
            if (ma !== null){
                cmd = ma[1];
                var args = ma[2].split(",");
                for (var j in args){
                    if (args[j].match(this.rInt)){
                        args[j] = parseInt(args[j], 10);
                    }
                }
                console.log(cmd);
                console.log(args);
                ret = this[cmd].apply(this, args);
            } else {
                console.log(cmd);
                ret = this[cmd].apply(this);
            }
        }

        return ret;
    };

    /////////////////////////////////////////////////////////////////////////////
    // Mode switching
    var VprotoModeSwitching = {
        toMode: function(mode) {
            this.mode = mode;
            this.keyscope = this.keymap[mode];
            this.$modedisplay.text(mode.toUpperCase());
            this.$wrap.removeClass().addClass("vimarea-wrap " + mode);
        },
        toNormalMode: function() {
            this.toMode("normal");
        },
        toInsertMode: function() {
            this.toMode("insert");
        }
    };
    $.extend(Vproto, VprotoModeSwitching);

    /////////////////////////////////////////////////////////////////////////////
    // Settings and registers
    var VprotoSettings = {
        set: function(key, value) {
            if (value !== undefined){
                this.settings[key] = value;
            } else {
                return this.settings[key];
            }
        },

        reg: function(name, value){
            if (value !== undefined) {
                this.regs[name] = value;
            } else {
                return this.regs[name];
            }
        }
    };
    $.extend(Vproto, VprotoSettings);

    /////////////////////////////////////////////////////////////////////////////
    // Text-wide accessors
    var VprotoTextAccess = {
        val: function(text) {
            if (text === undefined) {
                return this.$a.val();
            } else {
                return this.$a.val(text);
            }
        },

        substring: function(start, end) {
            return this.val().substring(start, end);
        },

        pos: function(){
            return this.$a.prop('selectionEnd');
        },

        col: function(){
            return this.pos() - this.lineStart();
        },

        textBefore : function() {
            return this.substring(0, this.pos());
        },

        textAfter : function() {
            return this.substring(this.pos());
        },

        textLength: function(){
            return this.val().length;
        },

        charAt: function(pos){
            return this.val().charAt(pos);
        },

        lineStart : function() {
            return this.textBefore().lastIndexOf("\n") + 1;
        },

        lineEnd : function() {
            return this.pos() + this.textAfter().indexOf("\n");
        },

        lineLength : function() {
            return this.lineEnd() - this.lineStart();
        }
    };
    $.extend(Vproto, VprotoTextAccess);



    /////////////////////////////////////////////////////////////////////////////
    // Caret movement
    var VprotoCaretMovement = {
        moveto: function(pos){
            this.$a.prop('selectionStart', pos);
            this.$a.prop('selectionEnd',   pos);
        },

        movetoLineStart: function(){
            this.moveto(this.lineStart());
        },

        movetoLineEnd: function(){
            this.moveto(this.lineEnd());
        },

        movetoStart: function(){
            this.moveto(0);
        },

        movetoEnd: function(){
            this.moveto(this.textLength());
        },

        moveVert: function(number){
            if (number === 0) { return; }
            var col = this.col();
            for (var i=0; i < Math.abs(number); i++){
                if (number > 0) {
                    this.movetoLineEnd();
                    this.move(1);
                } else {
                    this.movetoLineStart();
                    this.move(-1);
                    this.movetoLineStart();
                }
            }
            this.move(Math.min(col, this.lineLength()));
        },

        move : function(number) {
            this.moveto(this.pos() + number);
        },

        vselect: function(start, end) {
            this.$a.prop('selectionStart', start);
            this.$a.prop('selectionEnd', end);
        },

        vstart: function(number) {
            if (number === undefined){
                return this.$a.prop('selectionStart');
            } else {
                this.$a.prop('selectionStart', this.vstart()+number);
            }
        },

        vend: function(number){
            if (number === undefined){
                return this.$a.prop('selectionEnd');
            } else {
                this.$a.prop('selectionEnd', this.vstart()+number);
            }
        }
    };
    $.extend(Vproto, VprotoCaretMovement);


    /////////////////////////////////////////////////////////////////////////////
    // Text manipulation
    var VprotoTextModify = {

        backspace: function(number) {
            var pos = this.pos();
            var char_before = this.charAt(pos-1);

            if (char_before == " " && this.settings.tabchar != "\t") {
                var tabchar = this.settings.tabchar;
                var chars_before = (this.substring(pos - tabchar.length, pos));
                if (chars_before == tabchar) {
                    this.deleteBackward(tabchar.length);
                    this.keyPreventDefault();
                }
            } else {
            }
        },

        deleteBackward : function(number){
            var pos = this.pos();
            this.moveto(pos);
            var newtext = this.textBefore().substring(0, pos - number);
            newtext    += this.textAfter();
            this.val(newtext);
            this.moveto(pos - number);
        },

        deleteText: function(start, end) {
            var yank = this.substring(start, end);
            var newtext = this.substring(0, start);
            newtext    += this.substring(end);
            this.val(newtext);
            this.reg('"', yank);
        },

        deleteLine: function(){
            var start = this.lineStart();
            var end = this.lineEnd()+1;
            var col = this.col();
            this.deleteText(start, end);
            this.moveto(start);
            this.move(Math.min(col, this.lineLength()));
        },

        insertText : function(text) {
            var pos = this.pos();
            var newtext = this.textBefore();
            newtext    += text;
            newtext    += this.textAfter();
            this.val(newtext);
            this.moveto(pos + text.length);
        },

        insertTab: function() {
            this.insertText(this.settings.tabchar);
            this.keyPreventDefault();
        },

        insertNewline: function(){
            this.insertText("\n");
        },

        paste: function(regname){
            if (regname === undefined) { regname = '"'; }
            var reg = this.reg(regname);
            if (reg.charAt(reg.length-1) == "\n"){
                this.movetoLineEnd();
                this.move(1);
                this.insertText(reg);
                this.move(-1);
            } else {
                this.move(1);
                this.insertText(reg);
            }
        }
    };
    $.extend(Vproto, VprotoTextModify);


    /////////////////////////////////////////////////////////////////////////////
    // Other commands
    // Help
    var VprotoOther = {
        help: function(){
            this.$a.one('keyup', $.proxy(function(e){
                this.deleteBackward(3);
            }, this));
        },

        // Save
        save: function(){
            this.keyPreventDefault();
            this.onSave();
        }
    };
    $.extend(Vproto, VprotoOther);



    /////////////////////////////////////////////////////////////////////////////
    // DOM
    /////////////////////////////////////////////////////////////////////////////
    // Build the necessary DOM elements.
    Vproto.buildElements = function(){
        this.$wrap = $('<div class="vimarea-wrap">')
                    .css("margin", "0px").css("padding", "0px").css("position", "relative")
                    .css("border", "0px").css("display", "block");
        this.$modedisplay = $('<span class="vimarea-modedisplay">')
                    .css("margin", "0px").css("padding", "3px 5px").css("position", "absolute")
                    .css("bottom", "0px").css("right", "0px")
                    .css("display", "inline-block")
                    .css("color", "#FFFFFF").css("font-family", "monospace")
                    .css("line-height", "13px").css("font-size", "13px");

        this.$wrap.insertBefore(this.$a);
        this.$wrap.append(this.$a);
        this.$wrap.append(this.$modedisplay);

        var css = '';
        css += '<style type="text/css">';
        css += '    .vimarea-wrap.insert textarea { background: #FFFFFF; color: $baseFontColor; }';
        css += '    .vimarea-wrap.normal textarea { background: #F0F0F0; color: $baseFontColor; }';
        css += '    .vimarea-wrap.insert .vimarea-modedisplay { background: #999999; color: #FFF; }';
        css += '    .vimarea-wrap.normal .vimarea-modedisplay { background: #694A4A; color: #FFF; }';
        css += '</style>';
        this.$css = $(css);
        this.$css.appendTo($('head'));
    };

    /////////////////////////////////////////////////////////////////////////////
    // Helpers
    /////////////////////////////////////////////////////////////////////////////
    function compact(array){
        var result = [];
        for (var i in array){
            if (!isBlank(array[i])) { result.push(array[i]); }
        }
        return result;
    }

    function strip(str){
        return str.replace(/^\s+|\s+$/g, '');
    }

    function type(obj) {
        var typestr = Object.prototype.toString.call(obj);
        return typestr.substring(8, typestr.length-1);
    }

    function isBlank(obj) {
        if (obj === null || obj === undefined) { return true; }

        var tipe = type(obj);

        if (tipe == "String" || tipe == "Array"){
            if (obj.length === 0) { return true; }
        }

        if (tipe == "Object"){
            for (var i in obj) {
                if (obj.hasOwnProperty(i)) { return false; }
            }
            return true;
        }

        return false;
    }

    window.type = type;
    window.isBlank = isBlank;
    window.compact = compact;

})(jQuery);

