function Game(boardElm, boardBackgroundElm){
    this.mode = "hvh";
    this.rounds = 0;
    var white, black,
        playing = false,
        history = [],
        players = {},
        board = new Board(boardElm, boardBackgroundElm),
        currentColor = "black",       
		countundo=0;

    board.clicked = function(r, c){
        var p = players[currentColor];
        if(p instanceof HumanPlayer){
            p.setGo(r, c);
        }
    };
    
    this.getundo =function(){
        return countundo;
    }
    this.getHistory=function(){
        return history;
    }

    this.getCurrentPlayer = function(){
        return players[currentColor];
    };

    this.setCurrentColor = function(color){
        currentColor = color;
    };

    this.toHuman = function(color){
        board.setClickable(true, color);
    };

    this.toOthers = function(){
        board.setClickable(false);
    };

    this.update = function(r, c, color){
        if(playing){
            this.rounds++;
            board.updateMap(r, c, color);
            black.watch(r, c, color);
            white.watch(r, c, color);
            setTimeout(progress, 0);
        }
    };

    function progress(){
        if(currentColor === 'black'){
            white.myTurn();
        }else{
            black.myTurn();
        }
    }

    this.setGo = function(r, c, color){
        if(!playing || board.isSet(r, c))return false;
        history.push({
            r: r,
            c: c,
            color:color
        });
        board.highlight(r, c);
        board.setGo(r, c, color);
        var result = board.getGameResult(r, c, color);

        if(result === "draw"){
            this.draw();
        }else if(result === "win"){
            this.win();
            board.winChange(r, c, color);// 改变棋子颜色
        }else{
            this.update(r, c, color);
        }
		
		
	
		var audio = document.getElementById("audio");
		audio.src = 'sound/chess.mp3'; 
		
		var playPromise = audio.play();

		if (playPromise) {
			playPromise.then(() => {
				// 音频加载成功
				// 音频的播放需要耗时
				setTimeout(() => {
					// 后续操作
					//console.log("play.");
				}, audio.duration * 1000); // audio.duration 为音频的时长单位为秒

			}).catch((e) => {
				// 音频加载失败
			});
		}
		
        return true;
    };

    this.undo = function(){
        if(!playing){
            if(!history.length)return;
            var last = history.pop();
            board.unsetGo(last.r,last.c);
            white.watch(last.r,last.c,'remove');
            black.watch(last.r,last.c,'remove');
            return;
        }
        do{
            if(!history.length)return;
            var last = history.pop();
            board.unsetGo(last.r,last.c);
            white.watch(last.r,last.c,'remove');
            black.watch(last.r,last.c,'remove');
        }while(players[last.color] instanceof AIPlayer);
        var last = history[history.length - 1];
        if(history.length > 0) board.highlight(last.r, last.c);
        else board.unHighlight();
        players[last.color].other.myTurn();
        for(var col in {'black':'','white':''}){
            if(players[col] instanceof AIPlayer && players[col].computing){
                players[col].cancel++;
            }
        }
        countundo++;
    };

    this.draw = function(){
        playing = false;
        board.setClickable(false);
    };

    this.win = function(){
        playing = false;
        board.setClickable(false);
        showWinDialog(this);
    };

    this.init = function(player1, player2){
        console.log(player1, player2);
        this.rounds = 0;
        history = [];
        board.init();
        players = {};
        players[player1.color] = player1;
        players[player2.color] = player2;
        white = players['white'];
        black = players['black'];
        white.game = this;
        black.game = this;
        white.other = black;
        black.other = white;
        if(!(black instanceof HumanPlayer)){
            board.setWarning(0, true);
        }

        if(!(white instanceof HumanPlayer)){
            board.setWarning(1, true);
        }
    };

    this.start = function(){
        playing = true;
        players.black.myTurn();
    };
}