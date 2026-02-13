$(document).ready(function(){
    var game = new Game($(".go-board"), $(".board tbody"));

    var adjustSize = adjustSizeGen();

    $(window).resize(adjustSize);

    adjustSize();
    $.mobile.defaultDialogTransition = 'flip';
    $.mobile.defaultPageTransition = 'flip';
    
    $('#mode-select input[type="radio"]').on('change', function(){
        gameData.mode=$(this).val();
    });
    
    $('#color-select input[type="radio"]').on('change', function(){
        gameData.color=$(this).val();
    });
    
    $('#level-select input[type="radio"]').on('change', function(){
        gameData.level=$(this).val();
    });
    
    $('.back-to-game').on('tap',function(){
        $.mobile.changePage('#game-page');
    });
    
    $("#start-game").on('click',function(){
        try{
            game.white.worker.terminate();
            game.black.worker.terminate();
        }catch(e){}
        if(gameData.mode==='vshuman'){
            game.mode='hvh';
            game.init(new HumanPlayer("black"), new HumanPlayer("white"));
        }else{
            var color, other;
            if(gameData.color==='black'){
                color='black';
                other='white';
            }else{
                color='white';
                other='black';
            }
            game.mode=gameData.level;
            game.init(new HumanPlayer(color), new AIPlayer(game.mode, other));
        }
        $.mobile.changePage('#game-page');
        game.start();
        setTimeout(function(){$('.back-to-game').button('enable');},100);
    });

    $("#undo-button").on('tap', function(){
        game.undo();
    });
    
    $('.fullscreen-wrapper').on('tap', function(){
        $(this).hide();
        $.mobile.changePage('#game-won');
    });
    
    $('#new-game').page();
    $('#game-won').page();
    gameData.load();
    $('.back-to-game').button('disable');
    $.mobile.changePage('#new-game',{changeHash: false});

    window.gameInfo = (function(){
        var blinking = false,
            text = "",
            color = "";

        var self = {};

        self.getBlinking = function(){
            return blinking;
        };

        var mainObj = $("#game-info");
        self.setBlinking = function(val){
            if(val !== blinking){
                blinking = val;
                if(val){
                    mainObj.addClass("blinking");
                }else{
                    mainObj.removeClass("blinking");
                }
            }
        };

        self.getText = function(){
            return text;
        };

        var textObj = $("#game-info>.cont");
        self.setText = function(val){
            text = val;
            textObj.html(val);
        };

        self.getColor = function(){
            return color;
        };

        var colorObj = $("#game-info>.go");
        self.setColor = function(color){
            colorObj.removeClass("white").removeClass("black");
            if(color){
                colorObj.addClass(color);
            }
        };

        return self;
    })();
});

function showWinDialog(game){
    gameInfo.setBlinking(false);
    if(game.mode === 'hvh'){
        var who=(function(string){ return string.charAt(0).toUpperCase() + string.slice(1);})(game.getCurrentPlayer().color);
        $("#game-won h4").html(who+' 赢了!');
        gameInfo.value=who+' 赢了。'
        $("#win-content").html(who+' 赢了比赛。再来一局?');
        $('#happy-outer').fadeIn(500);
    }else{
        if(game.getCurrentPlayer() instanceof HumanPlayer){
            $("#game-won h4").html(guser+'，你赢了!');
            $("#win-content").html(guser + '，你赢了。 再来一局?');
            gameInfo.value = guser + '，你赢了。'
            $('#happy-outer').fadeIn(500);
            SaveLevel(game);
        }else{
            $("#game-won h4").html(guser + '，你输了。');
            $("#win-content").html(guser + '，你输了。 再来一局?');
            gameInfo.value='电脑赢了。'
            $('#sad-outer').fadeIn(500);
        }
    }
}

//自动保存成绩

function SaveLevel(game) {
    var formData = new FormData();
    formData.append('History', game.getHistory());
    formData.append('Mode', game.mode);
    formData.append('Undo', game.getundo());
    var saveurl = "wuziqi.ashx?Title=wuziqi&Mode=" + game.mode + "&Rounds=" + game.rounds;
    $.ajax({
        url: saveurl,
        type: "POST",
        cache: false,
        data: formData,
        dataType: "html",
        processData: false,
        contentType: false
    }).done(function (res) {
        console.log(res);
    }).fail(function (res) {
        console.log("保存失败");
    });
}