/**
 * @author mrdoob / http://mrdoob.com/
 */

THREE.PointerLockControls = function ( camera ) {

	//this.default_v = 800;
	this.default_v = 20000; //10000
	this.fast_v = 40000;
	this.v = this.default_v;
	this.slow_v = 2000;
	this.default_y = 20;
	this.jumpingOn = true;
	
	this.pathlength = 0;

	var lockMoveForward = false;
	var lockMoveBackward = false;
	var lockMoveLeft = false;
	var lockMoveRight = false;

	var scope = this;

	camera.rotation.set( 0, 0, 0 );

	var pitchObject = new THREE.Object3D();
	pitchObject.add( camera );

	var yawObject = new THREE.Object3D();
	yawObject.position.y = this.default_y;
	yawObject.add( pitchObject );

	var moveForward = false;
	var moveBackward = false;
	var moveLeft = false;
	var moveRight = false;
	this.moving = false;

	var isOnObject = false;
	var canJump = false;

	var prevTime = performance.now();

	var velocity = new THREE.Vector3();

	var PI_2 = Math.PI / 2;

	var onMouseMove = function ( event ) {

		if ( scope.enabled === false ) return;

		var movementX = event.movementX || event.mozMovementX || event.webkitMovementX || 0;
		var movementY = event.movementY || event.mozMovementY || event.webkitMovementY || 0;

		yawObject.rotation.y -= movementX * 0.002;
		pitchObject.rotation.x -= movementY * 0.002;

		//pitchObject.rotation.x = Math.max( - PI_2, Math.min( PI_2, pitchObject.rotation.x ) );
		
		pitchObject.rotation.x = Math.max( - 0.3, Math.min( 0.35, pitchObject.rotation.x ) );

	};
	
	var onClick = function ( event ) {
		/*if ($ && $("#blocker")) {
			$("#blocker").hide();
			scope.enabled = true;
		}*/
		pointerlockchange();
	};

	var onKeyUp = function ( event ) {
		
		switch( event.keyCode ) {

			case 38: // up
			case 87: // w
				moveForward = false;
				break;

			case 37: // left
			case 65: // a
				moveLeft = false;
				break;

			case 40: // down
			case 83: // s
				moveBackward = false;
				break;

			case 39: // right
			case 68: // d
				moveRight = false;
				break;

		}

	};

	var onKeyDown = function ( event ) {

		switch ( event.keyCode ) {

			case 38: // up
			case 87: // w
				moveForward = true;
				break;

			case 37: // left
			case 65: // a
				moveLeft = true; break;

			case 40: // down
			case 83: // s
				moveBackward = true;
				break;

			case 39: // right
			case 68: // d
				moveRight = true;
				break;

			case 32: // space
				if ( canJump === true && this.jumpingOn === true ) velocity.y += 350;
				canJump = false;
				break;
		}

		if (event.keyCode == 16) {
			if (scope.v == scope.default_v)
				scope.v = scope.fast_v;
			else 
				scope.v = scope.default_v;
		}
	};
	

	document.addEventListener( 'mousemove', onMouseMove, false );
	document.addEventListener( 'click', onClick, false );
	document.addEventListener( 'keydown', onKeyDown, false );
	document.addEventListener( 'keyup', onKeyUp, false );

	this.enabled = false;

	this.getObject = function () {

		return yawObject;

	};

	this.isOnObject = function ( boolean ) {

		isOnObject = boolean;
		canJump = boolean;

	};

	this.getDirection = function() {

		// assumes the camera itself is not rotated

		var direction = new THREE.Vector3( 0, 0, -1 );
		var rotation = new THREE.Euler( 0, 0, 0, "YXZ" );

		return function( v ) {

			rotation.set( pitchObject.rotation.x, yawObject.rotation.y, 0 );

			v.copy( direction ).applyEuler( rotation );

			return v;

		}

	}();
	
	this.setDirection = function(x, y, z) {
		pitchObject.rotation.x = x;
		pitchObject.rotation.y = y;
		pitchObject.rotation.z = z;
	}

	this.update = function () {
		this.moving = moveForward || moveBackward || moveLeft || moveRight;

		if ( scope.enabled === false ) return;

		var time = performance.now();
		var delta = ( time - prevTime ) / 1000;

		velocity.x -= velocity.x * 10.0 * delta;
		velocity.z -= velocity.z * 10.0 * delta;

		velocity.y -= 9.8 * 100.0 * delta; // 100.0 = mass

		if ( moveForward  && !lockMoveForward ) velocity.z -= this.v * delta;
		if ( moveBackward  && !lockMoveBackward ) velocity.z += this.v * delta;

		if ( moveLeft && !lockMoveLeft ) velocity.x -= this.v * delta;
		if ( moveRight && !lockMoveRight) velocity.x += this.v * delta;

		if ( isOnObject === true ) {

			velocity.y = Math.max( 0, velocity.y );

		}

		var x1 = yawObject.position.x, z1 = yawObject.position.z;
		yawObject.translateX( velocity.x * delta );
		yawObject.translateY( velocity.y * delta );
		yawObject.translateZ( velocity.z * delta );
		var x2 = yawObject.position.x, z2 = yawObject.position.z;
		
		scope.pathlength += Math.sqrt(Math.pow(x2-x1, 2)+Math.pow(z2-z1, 2));

		if ( yawObject.position.y < this.default_y ) {

			velocity.y = 0;
			yawObject.position.y = this.default_y;

			canJump = true;

		}

		prevTime = time;

	};

	this.moveLeft = function() {
		return moveLeft;
	};
	
	this.moveRight = function() {
		return moveRight;
	};
	
	this.moveForward = function() {
		return moveForward;
	};
	
	this.moveBackward = function() {
		return moveBackward;
	};

	this.lockMoveForward = function(boolean){
		lockMoveForward = boolean;
		velocity.z = 0;
	};
	
	this.lockMoveBackward = function(boolean){
		lockMoveBackward = boolean;
		velocity.z = 0;
	};
	
	this.lockMoveLeft = function(boolean){
		lockMoveLeft = boolean;
		velocity.x = 0;
	};
	
	this.lockMoveRight = function(boolean){
		lockMoveRight = boolean;
		velocity.x = 0;
	};

};
