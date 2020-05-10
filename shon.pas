program Shon;
{$librarypath '../mads/blibs/'}
uses atari, crt, joystick, rmt, b_crt;

const
{$i const.inc}
    // display list is translated to asm in dlist_title.asm
    // bellow code taken from g2f is left here for comparison 
	// dlist: array [0..34] of byte = (
	// 	$C4,lo(scr),hi(scr),
	// 	$84,$84,$84,$84,$84,$84,$84,$84,
	// 	$84,$84,$84,$84,$84,$84,$84,$84,
	// 	$84,$84,$84,$84,$84,$84,$84,$84,
	// 	$84,$84,$84,$84,$04,
	// 	$41,lo(word(@dlist)),hi(word(@dlist))
	// );

    // 
	fntTable: array [0..29] of byte = (
		hi(CHARSET_TITLE1),hi(CHARSET_TITLE1),hi(CHARSET_TITLE1),hi(CHARSET_TITLE1),hi(CHARSET_TITLE1),hi(CHARSET_TITLE1),hi(CHARSET_TITLE1),hi(CHARSET_TITLE1),
		hi(CHARSET_TITLE1),hi(CHARSET_TITLE1),hi(CHARSET_TITLE1),hi(CHARSET_TITLE1),hi(CHARSET_TITLE1),hi(CHARSET_TITLE2),hi(CHARSET_TITLE2),hi(CHARSET_TITLE2),
		hi(CHARSET_TITLE2),hi(CHARSET_TITLE2),hi(CHARSET_TITLE2),hi(CHARSET_TITLE2),hi(CHARSET_TITLE3),hi(CHARSET_TITLE2),hi(CHARSET_TITLE3),hi(CHARSET_TITLE3),
		hi(CHARSET_TITLE3),hi(CHARSET_TITLE3),hi(CHARSET_TITLE3),hi(CHARSET_GAME),hi(CHARSET_GAME),hi(CHARSET_GAME)
	);

	c0Table: array [0..29] of byte = (
		$10,$10,$10,$10,$10,$10,$10,$10,
		$10,$10,$10,$10,$10,$10,$10,$10,
		$D4,$D4,$D4,$D4,$D4,$D4,$D4,$D4,
		$D4,$D4,$D4,$D4,$D4,$00
	);

	c1Table: array [0..29] of byte = (
		$14,$14,$14,$14,$14,$14,$14,$14,
		$14,$14,$14,$14,$14,$14,$14,$14,
		$D8,$D8,$D8,$D8,$D8,$D8,$D8,$D8,
		$D8,$D8,$D8,$D8,$D8,$00
	);

	c2Table: array [0..29] of byte = (
		$1C,$1C,$1C,$1C,$1C,$1C,$1C,$1C,
		$8E,$1C,$1C,$1C,$1C,$1C,$1C,$1C,
		$DC,$DC,$DC,$DC,$DC,$DC,$DC,$DC,
		$DC,$DC,$DC,$DC,$DC,$00
	);

	c3Table: array [0..29] of byte = (
		$0E,$0E,$8E,$8C,$8A,$86,$84,$82,
		$80,$00,$02,$04,$06,$08,$0A,$0C,
		$FC,$FC,$FC,$FC,$FC,$FC,$FC,$FC,
		$FC,$FC,$FC,$FC,$FC,$00
	);


{$r resources.rc}               // including resource files with all assets
{$i types.inc}                  // including defined type

var
    gamestate: TGameState;
    music: Boolean;

    msx: TRMT;
    old_vbl,old_dli:pointer;

{$i 'strings.inc'}              // including strings
{$i interrupts.inc}

// -----------------------------------------------------------------------------
// auxiliary procedures

procedure print_top( x: Byte; s: String);
// prints string at x position on top row (1 line)
begin
  CRT_Init(SCREEN_TOP);
  CRT_GotoXY(x,0);
  CRT_Write(s);
end;





// -----------------------------------------------------------------------------


procedure show_title;
// Procedure to display title screen on start
begin
    SetIntVec(iVBL, @vbl_title);
    SetIntVec(iDLI, @dli_title);
    // sdlstl := word(@dlist_title);	// ($230) = @dlist_title, New DLIST Program
    SDLSTL := DISPLAY_LIST_TITLE;
    savmsc:= SCREEN_TITLE;

    fillbyte(pointer(SCREEN_TITLE+1080), 120, 0);   // size 120 (3 x 40 chars in 1 line); + 960 of screen (40 x 24 chars) + (3 x 40 chars) for last 3 lines;
    
    repeat
        pause;
    until (consol = CN_START) or (strig0 = 0 );
    gamestate:=GAMEINPROGRESS;
end;

// -----------------------------------------------------------------------------

procedure show_game;
// main game procedure
// displays game screen
begin
    SetIntVec(iVBL, @vbl_game);
    SetIntVec(iDLI, @dli_game);
    sdmctl := byte(normal or enable or missiles or players or oneline);
    SDLSTL := DISPLAY_LIST_GAME;
    chbas:= Hi(CHARSET_GAME);



    CRT_Init(SCREEN_TOP);
    fillbyte(pointer(SCREEN_TOP), 40, 0);      // size 40 (40 x 1 chars);
    CRT_Init(SCREEN_GAME);
    fillbyte(pointer(SCREEN_GAME), 792, 0);    // size 720 (40 x 18 chars);
    CRT_Init(SCREEN_BOTTOM);
    fillbyte(pointer(SCREEN_BOTTOM), 40, 0);   // size 40 (40 x 1 chars);

    // print_top(0,'SHON'~);
    

    repeat
        pause;pause;
    until keypressed;

    //temporarly to test loop
    gamestate:= GAMEOVER
end;

// -----------------------------------------------------------------------------
// Main
// -----------------------------------------------------------------------------
begin
    CursorOff;
    Randomize;
    //chbas := Hi(CHARSET_ADDRESS); // set custom charset

(*  initialize RMT player  *)
    msx.player := pointer(RMT_PLAYER_ADDRESS);
    msx.modul := pointer(RMT_MODULE_TITLE);
    msx.Init(0);


    sdmctl := byte(normal or enable or missiles or players or oneline);

(*  set and run vbl interrupt *)
    GetIntVec(iVBL, old_vbl);
    GetIntVec(iDLI, old_dli);

(*  set and run display list interrupts *)
    nmien := $c0;			// $D40E = $C0, Enable DLI
    
(*  your code goes here *)
    // clearing up screen memory space
    // size depends on display list dlist_game.asm


    music:=false;    
    gamestate:= GAMEINPROGRESS; // NEWGAME;

    while true do
    begin
      case gamestate of
        NEWGAME: show_title;
        GAMEINPROGRESS: show_game;
        // GAMEOVER: gameover;
      end;
    end;

        
(*  restore system interrupts *)
    // SetIntVec(iVBL, @old_vbl);
    // SetIntVec(iDLI, old_dli);
    // nmien := $40; // turn off dli

end.
