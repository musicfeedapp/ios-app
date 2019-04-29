'use strict'

angular.module('app', [
    'ngAnimate',
    'appDirectives',
    'appControllers'
]);

angular.module('appDirectives', []);
angular.module('appControllers', []);



angular.module('appControllers').controller('AppController', ['$scope', function( $scope ) {

    // $scope.showVideo = false;

    $scope.panes = [{
        text:  'Keep track of your friends and\n\
                favorite artists\' music posts'
    },{
        text:  'Listen to tracks and watch videos\n\
                directly in your feed'
    },{
        text:  'Heart your biggest faves and share\n\
                your love for the music'
    },{
        text:  'Remove tracks you dont like so\n\
                musicfeed can learn your preferences'
    }];

}]);;

'use strict'

/*//////////////////////////////

    super simple carousel

    @see thecoded.com/swipe/examples/carousel.html
    @req hammer.js

//////////////////////////////*/



angular.module('appDirectives').directive('carousel', function() {

    if ( !Hammer )
        return console.error( 'missing Hammer.js' );

    function Carousel( $scope, $element, attributes ) {

        var $strip = $element.find('>ul'),
            numPanes = $scope.panes.length || attributes.numPanes || $element.find('>ul >li').length || 1,
            singlePaneOffset = -100 / numPanes,
            paneW = 0,
            hitarea = typeof attributes.hitarea !== 'undefined',
            autoplay = typeof attributes.autoplay !== 'undefined',
            bulletControl = typeof attributes.bulletControl !== 'undefined',
            impedeAutoPlayTimeout,
            autoPlayInt,
            autoPauseTime = attributes.autoPauseTime || 8000,
            mc = new Hammer.Manager(
                $element[0], {
                    preventDefault: true,
                    touchAction: 'none'
                }),
            panH = new Hammer.Pan({
                event: 'panh',
                direction: Hammer.DIRECTION_HORIZONTAL
            }),
            swipeH = new Hammer.Swipe({
                event: 'swipeh',
                direction: Hammer.DIRECTION_HORIZONTAL
            });

        mc.add( panH );
        mc.add( swipeH ).recognizeWith( panH );

        mc.on('swipeh panh', handleHammer );

        $scope.stripOffset = 0;
        $scope.currentPane = 0;
        $scope.animate = false;
        $scope.slow = false;

        //  bullet business
        //
        $scope.bullets = [];
        $scope.bulletControl = bulletControl;

        for ( var i = 0; i < numPanes; i++ )
            $scope.bullets.push({ opacity: i==0 ? 1 : 0 });

        $scope.bulletControlNav = function( idx ) {

            if ( !$scope.bulletControl )
                return;

            setTimeout(function() {
                showPane( idx, true );
                impedeAutoPlay();
            });

        }


        //  get single pane width in px for
        //  we need compare it to deltaX
        //
        function setPaneW() { paneW = $element[0].offsetWidth; };

        angular.element( document ).ready( setPaneW );
        angular.element( window ).on('load resize orientationchange', setPaneW );
        

        //  perhaps not the best place or
        //  solution for this, but need it
        //  in home view
        //  
        function sizeHitArea( hitArea ) {

            if ( !jQuery )
                return;

            var viewW = jQuery('.view').width(),
                viewH = jQuery('.view').height();

            hitArea.css({
                'width': viewW,
                'height': viewH,
                'margin-left': -viewW / 2,
                'margin-top': -viewH / 2
            });

        }

        function makeHitArea() {

            var hitArea = angular.element('<div class="carousel-hitarea"></div>').appendTo( $element );

            angular.element( window ).on('load resize orientationchange', function(){
                sizeHitArea( hitArea )
            });

            sizeHitArea( hitArea );

            return hitArea;

        }

        if ( hitarea )
            makeHitArea();


        //  auto play intro (home page)
        //  
        $scope.autoplay = autoplay;

        function autoNext() {

            var nextPane = $scope.currentPane+1 >= numPanes ? 0 : $scope.currentPane + 1;
            
            showPane( nextPane, true, true );

        }

        function impedeAutoPlay() {

            if ( autoPlayInt )
                clearInterval( autoPlayInt );

            if ( impedeAutoPlayTimeout )
                clearTimeout( impedeAutoPlayTimeout );

            if ( $scope.autoplay )
                impedeAutoPlayTimeout = setTimeout( initAutoPlay, autoPauseTime * 2 );

        }

        function initAutoPlay() {

            autoPlayInt = setInterval( autoNext, autoPauseTime );

        }

        if ( $scope.autoplay )
            initAutoPlay();


        function showPane( index, animate, slow ) {
            
            $scope.$apply(function(){
                $scope.currentPane = Math.max( 0, Math.min( index, numPanes-1 ) );
            });

            setStripPosition( -100 / numPanes * $scope.currentPane, animate, slow );

        };


        function setStripPosition( percent, animate, slow ) {

            $scope.$apply(function(){
                $scope.animate = animate;
                $scope.slow = slow;
            });

            // $scope.$apply(function(){ $scope.stripOffset = percent; });
            
            if ( animate )
                setTimeout( function() { setStripPositionCSS( percent ) } );
            else
                setStripPositionCSS( percent );                

            $scope.$apply( setPaneState( percent, animate, slow ) );

        };

        function setStripPositionCSS( percent ) {

            /*if( Modernizr.csstransforms )
                $strip.css('transform', 'translate('+ percent +'%,0)');
            
            else*/
                $strip.css('left', ( percent * numPanes ) +'%' /*( paneW * numPanes / 100 * percent ) + 'px'*/ );

        }

        //  Set highlight of bullet indicators
        //  and panes opacity
        //
        function setPaneState( percent, animate, slow ) {

            var progress = percent / singlePaneOffset,
                deviation = progress - $scope.currentPane;

            //  don't mess with neither
            //  first bullet when trying ← prev,
            //  last bullet when trying next →
            //
            if ( 0 > progress || progress > numPanes - 1 )
                return;

            //  final == swipe / pan end
            if ( deviation == 0 )
                $scope.bullets.map( function( b, i ){
                    b.opacity = ( i == $scope.currentPane ? 1 : 0 );
                });

            //  pan ← prev / next →
            else {
                
                var destBulletOpacity = Math.abs( deviation ),
                    currBulletOpacity = 1 - destBulletOpacity;

                $scope.bullets[ $scope.currentPane ].opacity = currBulletOpacity;
                $scope.bullets[ $scope.currentPane + ( 0 < deviation ? 1 : -1 ) ].opacity = destBulletOpacity;

            }

        }


        function next() { return showPane( $scope.currentPane + 1, true ); };
        function prev() { return showPane( $scope.currentPane - 1, true ); };


        function handleHammer( evt ) {
            
            // console.debug( evt );

            impedeAutoPlay();

            evt.preventDefault();

            switch( evt.type ) {

                case 'panh':

                    // console.debug( 'pan: '+( evt.offsetDirection == 4 ? 'next →' : '← prev') );
                    
                    var currentPaneOffset = singlePaneOffset * $scope.currentPane,
                        dragOffset = Math.max( singlePaneOffset, Math.min( -singlePaneOffset, ( 100 / paneW * evt.deltaX ) / numPanes ) );

                    //  resist first & last pane
                    //
                    if (
                        ( $scope.currentPane == 0          && evt.offsetDirection == 2 ) ||
                        ( $scope.currentPane == numPanes-1 && evt.offsetDirection == 4 )
                    )
                        dragOffset *= .2;

                    setStripPosition( currentPaneOffset + dragOffset );

                    // pan finished
                    //
                    if ( evt.isFinal ) {

                        //  more than 50% panned so
                        //  navigate to next/prev
                        //
                        if ( Math.abs( evt.deltaX ) > paneW/2 ) {
                        
                            if ( evt.offsetDirection == 4 )
                                next();

                            else
                                prev();

                        } else
                            showPane( $scope.currentPane, true );

                    }

                    break;

                case 'swipeh':

                    // console.debug( 'swipe: '+( evt.direction == 2 ? 'next →' : '← prev') );

                    //  cancel if more than 50% panned
                    //  to prevent navigating next/prev twice
                    //  
                    if ( Math.abs( evt.deltaX ) > paneW/2 )
                        break;

                    if ( evt.direction == 2 )
                        next();

                    if ( evt.direction == 4 )
                        prev();

            }
        
        };

    };

    /*function carouselController( $scope ) {

    };*/
    
    return ({
        restrict: 'AEC',
        templateUrl: 'carousel.html',
        // transclude: true,
        link: Carousel,
        // controller: carouselController
    });

});

'use strict'

/*//////////////////////////////

    super simple carousel

    @see thecoded.com/swipe/examples/carousel.html
    @req hammer.js

//////////////////////////////*/



angular.module('appDirectives').directive('introAppUi', ['$q', '$timeout', '$animate', '$window', function( $q, $timeout, $animate, $window ) {

    function Intro( $scope, $element, attributes ) {

        var //  bright sampled from:
            //  developer.apple.com/library/iOS/documentation/userexperience/conceptual/mobilehig/ColorImagesText.html
            //
            /*colors = [
                '#ff0038', // brand red // '#fe2d55', // red
                '#47cc5e', // green
                '#ffcc02', // yellow
                '#5ac8fa', // blue
            ],*/

            //  above with adjusted brightness 50%
            //
            /*colors = [
                '#7f162a', // red
                '#23662f', // green
                '#7f6601', // yellow
                '#2d647d', // blue
            ],*/
            
            //  all gray
            //
            /*colors = ['#333437'],*/
            colorNames = ['red', 'green', 'yellow', 'blue'],
            numColors = colorNames.length,
            animEndTime = Date.now(),
            incomingTimer, incomingInt,
            playTimer, playInt,
            loveTimer, loveInt,
            removeTimer, removeInt;


        $scope.tracks = [];

        //  have 6 tracks first
        //
        for ( var i = 0; i < 6; i++ )
            $scope.tracks.push({
                new: false,
                colorName: colorNames[ i % numColors ],
                // color: colors[ i % numColors ]
            });


        //  watch user panning/swiping
        //  panes and init/clear animations
        //
        $scope.$watch('currentPane', function( currPane, prevPane ){

            //  enter SCENE 1
            //
            if ( currPane == 0 ){
            
                incomingTimer = setTimeout( function() { 
                    incomingTrack();
                }, 500 );
                incomingInt = setInterval( incomingTrack, 2500 );
            
            }
            
            //  leave SCENE 1
            //
            //  note that prevPane == currPane == 0
            //  on first load
            //
            if ( prevPane == 0 && currPane !== 0 ) {
            
                clearTimeout( incomingTimer );
                clearInterval( incomingInt );
                // resetTracks('new');
            
            }


            //  enter SCENE 2
            //
            if ( currPane == 1 ) {

                playTimer = setTimeout( function() { 
                    playTrack( 'initial' );
                }, 500 );
                playInt = setInterval( playTrack, 8000 ); // that long because we want to show the full player too
            
            }
            
            //  leave SCENE 2
            //
            if ( prevPane == 1 ) {

                clearTimeout( playTimer );
                clearInterval( playInt );
                setTimeout( function() {
                    // we wait here beacuse it's ugly to cut play button tap animation
                    $animate.removeClass( angular.element('#feed li .play', $element ), 'click' );
                }, waitTime() );
                $animate.removeClass( angular.element('#player', $element ), 'full' );
                $animate.removeClass( angular.element('#player', $element ), 'visible', function() {
                    $animate.removeClass( angular.element('#play-progress', $element ), 'playing' );
                });
                resetTracks('play');
            
            }


            //  enter SCENE 3
            //
            if ( currPane == 2 ) {

                loveTimer = setTimeout( function() { 
                    loveTrack( 'initial' );
                }, 500 );
                loveInt = setInterval( loveTrack, 2500 );
            
            }
            
            //  leave SCENE 3
            //
            if ( prevPane == 2 ) {
            
                clearTimeout( loveTimer );
                clearInterval( loveInt );
                resetTracks('loved');
            
            }


            //  enter SCENE 4
            //
            if ( currPane == 3 ) {
            
                removeTimer = setTimeout( function() { 
                    removeTrack( 'initial' );
                }, 500 );
                removeInt = setInterval( removeTrack, 3500 );
            
            }

            //  leave SCENE 4
            //
            if ( prevPane == 3 ) {
            
                clearTimeout( removeTimer );
                clearInterval( removeInt );
                $animate.removeClass( angular.element('#feed li .remove', $element ), 'swiped' );
                $animate.removeClass( angular.element('#feed li .remove b', $element ), 'click' );
            
            }

        });

        $window.addEventListener('load', function() {
            angular.element('#track-video video').get(0).play();
        });


        //``````````````````````````````
        //  SCENE 1
        //
        //  prepend new tracks,
        //  pick colors in backwards order
        //
        function incomingTrack() {

            setTimeout( function() {

                $scope.$apply( function(){

                    var firstColorIndex = colorNames.indexOf( $scope.tracks[ 0 ].colorName ),
                        colorIndex = firstColorIndex==0 ? ( numColors - 1 ) : ( firstColorIndex - 1 );

                    $scope.tracks.unshift({
                        new: true,
                        colorName: colorNames[ colorIndex ],
                        // color: colors[ colorIndex ]
                    });
                    $scope.tracks.pop();

                });

                animEndTime = Date.now() + 500;

            }, waitTime() );

        }


        //``````````````````````````````
        //  SCENE 2
        //  
        //  tap play,
        //  show mini & full player
        //
        function playTrack( initial ) {

            setTimeout( function() {

                //  don't scroll the feed
                //  on stage entry, jus play
                //  the first track
                //
                if ( initial )
                    play();

                else
                    digFeed().then( play );
            
            }, waitTime() );

        }

        function play() {

            $timeout(function() {
                
                if ( $scope.currentPane !== 1 )
                    return;

                $animate.addClass( angular.element('#feed li .play', $element ).eq(0), 'click' );
                animEndTime = Date.now() + 600;

                invokePlayer();

            }, 300 ); // wait a lil (after scroll/scene entry) & tap to play

        }

        function invokePlayer() {
                
            $timeout(function() {

                if ( $scope.currentPane !== 1 )
                    return;

                var player = angular.element('#player', $element );
            
                if ( player.hasClass('visible') )
                    restartTrack();

                else {
                    $animate.addClass( player, 'visible', restartTrack );
                    animEndTime = Date.now() + 300;
                }
            
            }, 300 ); // wait jus a little after play-tap
            
        }
        
        function restartTrack() {
                        
            if ( $scope.currentPane !== 1 )
                return;

            var playProgress = angular.element('#play-progress', $element );

            if ( playProgress.hasClass('playing') )
                $animate.removeClass( playProgress, 'playing', startTrack );

            else
                startTrack();

        }

        function startTrack() {
            
            $animate.addClass( angular.element('#play-progress', $element ), 'playing' );

            openFullPlayer();

        }

        function openFullPlayer() {

            $timeout(function() {

                if ( $scope.currentPane !== 1 )
                    return;

                $animate.addClass( angular.element('#player', $element ), 'full' );

                animEndTime = Date.now() + 500;

                closeFullPlayer();

            }, 1500 ); // let the mini-player play a lil before opening the full player

        }

        function closeFullPlayer() {

            $timeout(function() {

                if ( $scope.currentPane !== 1 )
                    return;

                $animate.removeClass( angular.element('#player', $element ), 'full' );

            }, 3500 ); // let the full-player play a lil before closing it again

        }


        //``````````````````````````````
        //  SCENE 3
        //  
        //  tap hearts below tracks
        //
        function loveTrack( initial ) {
            
            setTimeout( function() {

                //  don't scroll the feed
                //  on stage entry, jus love
                //  the first track
                //
                if ( initial )
                    love();

                else
                    digFeed().then( love );

            }, waitTime() );

        }

        function love() {

            $timeout(function() {
                
                if ( $scope.currentPane !== 2 )
                    return;

                $animate.addClass( angular.element('#feed li .heart i', $element ).eq(0), 'loved' );
                $animate.addClass( angular.element('#feed li .heart b', $element ).eq(0), 'beat' );

                animEndTime = Date.now() + 600;


            }, 300 ); // wait a lil (after scroll/scene entry) & tap to love

            animEndTime = Date.now() + 300;

        }


        //``````````````````````````````
        //  SCENE 4
        //
        //  swipe tracks left to reveal
        //  trash can icons, tap to remove
        //
        function removeTrack( initial ) {
            
            setTimeout( function() {

                //  don't scroll the feed on
                //  stage entry, jus remove
                //  the first track
                //
                if ( initial )
                    swipeRemove();

                else
                    digFeed().then( swipeRemove );

            }, waitTime() );

        }

        function swipeRemove() {

            $timeout(function() {
                
                if ( $scope.currentPane !== 3 )
                    return;

                $animate.addClass( angular.element('#feed li .remove', $element ).eq(0), 'swiped', clickTrash );
            
                animEndTime = Date.now() + 200;

            }, 300 ); // wait a lil (after scroll/scene entry) & remove track

        }

        function clickTrash() {
            
            $timeout(function() {
                
                if ( $scope.currentPane !== 3 )
                    return;
                
                $animate.addClass( angular.element('#feed li .remove b', $element ).eq(0), 'click' );

                animEndTime = Date.now() + 600;
                
                $timeout( outgoingTrack, 200 );

            }, 300 );

        }

        function outgoingTrack() {
                
            if ( $scope.currentPane !== 3 )
                return;

            $animate.addClass( angular.element('#feed li', $element ).eq(0), 'dispose', disposeTrack );

            animEndTime = Date.now() + 500;

        }

        function disposeTrack() {

            $scope.$apply( function() {

                var lastColorIndex = colorNames.indexOf( $scope.tracks[ $scope.tracks.length-1 ].colorName );

                $scope.tracks.shift();
                $scope.tracks.push({
                    new: false,
                    colorName: colorNames[ ( lastColorIndex + 1 ) % numColors ]/*,
                    color: colors[ ( lastColorIndex + 1 ) % numColors ]*/
                });
            
            });

        }


        //``````````````````````````````
        //  Utils
        //

        //  scroll feed by 1 or 2 tracks,
        //  return a promise
        //  (used in scenes 1, 2, 3)
        //
        function digFeed( tracksToScroll ) {

            var tracksToScroll = tracksToScroll || 2,
                deferred = $q.defer(),
                firstTrack = angular.element('#feed li', $element ).eq(0);

            //  simulate feed scroll
            //  by css-animating top margin
            //  of first track in feed
            //
            $animate.addClass( firstTrack, 'scrolling' + ( tracksToScroll==1 ? '-one' : '' ),

                //  remove the first track(s)
                //  and prepend new one(s)
                //  once animation finishes
                //
                function() {

                    //  remove scrolled tracks
                    //
                    $scope.tracks.splice( 0, tracksToScroll );

                    //  append new tracks
                    //
                    var lastColorIndex = colorNames.indexOf( $scope.tracks[ $scope.tracks.length-1 ].colorName );

                    for (
                        var i = lastColorIndex + 1;
                            i < ( lastColorIndex + 1 + tracksToScroll );
                            i++
                    )
                        $scope.tracks.push({
                            new: false,
                            colorName: colorNames[ i % numColors ]/*,
                            color: colors[ i % numColors ]*/
                        });
                    
                    //  done digging
                    //
                    deferred.resolve();
                
                }
            );

            animEndTime = Date.now() + 1500;

            return deferred.promise;

        }

        //  reset tracks' new/play/loved states
        //
        function resetTracks( prop ) {

            if ( prop=='loved' ) {
                $animate.removeClass( angular.element('#feed li .heart i', $element ), 'loved' );
                $animate.removeClass( angular.element('#feed li .heart b', $element ), 'beat' );
            }

            if ( prop == 'play' )
                $animate.removeClass( angular.element('#feed li .play', $element ), 'click' );

            if ( prop == 'new' )
                for ( var i = 0; i < $scope.tracks.length; i++ ) {
                    $scope.tracks[ i ].new = false;
                }

        }

        //  get time to wait until previous
        //  animation ends (cached in animEndTime)
        // 
        function waitTime() {
        
            return Math.max( 0, animEndTime - Date.now() );
        
        }

    };
    
    return ({
        restrict: 'AEC',
        templateUrl: 'intro-app-ui.html',
        link: Intro
    });

}]);
