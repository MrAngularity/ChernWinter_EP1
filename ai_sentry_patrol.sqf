_leader = _this select 0;
_use_flare = _this select 1;

_side = side _leader;

_side_activation = switch (_side) do {
	case west:{"EAST"};
	case east:{"WEST"};
};

_side_detection = switch (_side) do {
	case west:{"WEST D"};
	case east:{"EAST D"};
};

_trg = createTrigger ["EmptyDetector", getpos _leader, false];
_trg setTriggerArea [250, 250, 0, false];
_trg setTriggerActivation [_side_activation, _side_detection, true];

_condition = "this and thisTrigger getVariable [""delay"",true]";

create_marker_function = {
	_m = createMarkerLocal [format ["warning_%1", date], getpos _this];
	_m setMarkerTypeLocal "hd_warning";
	_minutes = date select 4;
	if (count str(_minutes) < 2) then {_minutes = format["0%1",_minutes]};
	_m setMarkerTextLocal format ["%1:%2",date select 3, _minutes];
};

_activation = format ["
	(thisList select 0) remoteExec [""create_marker_function"", %1, true];
	null = thisTrigger spawn {sleep 60;_this setvariable [""delay"",true];};
	thisTrigger setvariable [""delay"",false];
",_side];

_activation_flare = "
	_vector = ( (getpos thisTrigger) vectorFromTo (getpos (thisList select 0)) ) ;
	flrObj = ""F_40mm_white"" createvehicle [(getpos thisTrigger select 0) + (_vector select 0)*100, (getpos thisTrigger select 1) + (_vector select 1)*100, 200];
	flrObj setVelocity [0,0,-10];
";

if (_use_flare) then {
	_activation = _activation +_activation_flare;
};

_activation_side_chat = format ["[%1, ""HQ""] sideChat ""Enemy Detected. Check your map!"";",_side];
_activation = _activation + _activation_side_chat;

_deactivation = "";

_trg setTriggerStatements [_condition, _activation, _deactivation];

_trg attachTo [_leader, [0,0,0]];

if(true)exitwith{hint _activation};