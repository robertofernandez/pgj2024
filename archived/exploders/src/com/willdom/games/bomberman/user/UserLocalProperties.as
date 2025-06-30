package com.willdom.games.bomberman.user
{
    import com.smartfoxserver.v2.entities.data.ISFSObject;
    import com.smartfoxserver.v2.entities.data.SFSObject;
    import com.willdom.games.bomberman.consts.PlayerVars;
    import com.willdom.games.bomberman.controllers.ConfigController;
    
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Loader;
    import flash.events.Event;
    import flash.net.URLRequest;
        
    public class UserLocalProperties
    {
        private var _isOnline:Boolean = true;
        private var _isFriend:Boolean = false;
        private var _isRegistered:Boolean = false;
        private var _invited:Boolean = false;
        private var _isInvitingMe:Boolean = false;
        private var _isReady:Boolean = false;
        private var _isPlaying:Boolean = false;
        private var _avatarInfo:AvatarInfo = new AvatarInfo();
        private var _skillPointsInfo:SkillPointsInfo = new SkillPointsInfo();
        private var _positionInWaitingList:int = 0;
        private var _ping:int = 0;
        private var _nationality:String = "undefined";
        private var avatarLoader:Loader = new Loader();
        
        public var pingVeryLow:Boolean = false;
        public var pingLow:Boolean = false;
        public var pingHigh:Boolean = false;
        public var pingVeryHigh:Boolean = false;
        
            
        public function UserLocalProperties()
        {
        }
        
        
        public function set avatarInfo(value:ISFSObject):void{
            _avatarInfo.smallAvatar = value.getUtfString(PlayerVars.SMALL_AVATAR);
            _avatarInfo.avatar = value.getUtfString(PlayerVars.AVATAR);
            _avatarInfo.largeAvatar = value.getUtfString(PlayerVars.LARGE_AVATAR);
            _avatarInfo.fullAvatar = value.getUtfString(PlayerVars.FULL_AVATAR);
        }
        
        
        public function get smallAvatar():String{
            if(_avatarInfo.smallAvatar==null && _avatarInfo.avatar==null){
                return "";
            }else if(_avatarInfo.smallAvatar==null){
                return _avatarInfo.avatar;
            }
            return _avatarInfo.smallAvatar;
        }
        
        public function set smallAvatar(value:String):void{
            _avatarInfo.smallAvatar=value;
        }
        
        public function get avatar():String
        {
            return _avatarInfo.avatar;
        }
        
        public function set avatar(value:String):void{
            _avatarInfo.avatar=value;
            
        }
        
        public function get largeAvatar():String{
            if(_avatarInfo.smallAvatar==null && _avatarInfo.avatar==null){
                return "";
            }else if(_avatarInfo.largeAvatar==null){
                return _avatarInfo.avatar;
            }
            return _avatarInfo.largeAvatar;
        }    
        
        public function set largeAvatar(value:String):void{
            _avatarInfo.largeAvatar = value;            
        }
        
        public function get fullAvatar():String{
            return _avatarInfo.fullAvatar;
        }    
        
        public function set fullAvatar(value:String):void{
            _avatarInfo.fullAvatar = value;            
        }
        
        public function set isPlaying(value:Boolean):void{
            _isPlaying = value;
        }
        
        public function get isPlaying():Boolean{
            return _isPlaying;
        }
        
        public function set isOnline(value:Boolean):void
        {
            _isOnline = value;
        }
        public function get isOnline():Boolean
        {
            return _isOnline;
        }
        
        public function set isRegistered(value:Boolean):void{
            _isRegistered = value;
        }
        
        public function get isRegistered():Boolean{
            return _isRegistered;
        }
        
        public function set isFriend(value:Boolean):void
        {
            _isFriend = value;
        }
        public function get isFriend():Boolean
        {
            return _isFriend;
        }
        public function set invited(value:Boolean):void
        {
            _invited = value;
        }
        public function get invited():Boolean
        {
            return _invited;
        }
        public function set isInvitingMe(value:Boolean):void
        {
            _isInvitingMe = value;
        }
        public function get isInvitingMe():Boolean
        {
            return _isInvitingMe;
        }
       
        public function set isReady(value:Boolean):void{
            _isReady = value;
        }
        
        public function get isReady():Boolean{
            return _isReady;
        }
        
        public function set skillPointsInfo(value:ISFSObject):void{
            var date:ISFSObject = value.getSFSObject(PlayerVars.ACTIVATION_DATE_PARAM);
            _skillPointsInfo.activationDay = date.getInt(PlayerVars.DAY_PARAM);
            _skillPointsInfo.activationMonth = date.getInt(PlayerVars.MONTH_PARAM);
            _skillPointsInfo.activationYear = date.getInt(PlayerVars.YEAR_PARAM);
            _skillPointsInfo.gamesLost = value.getInt(PlayerVars.LOST_PARAM);
            _skillPointsInfo.gamesWon = value.getInt(PlayerVars.WON_PARAM);
            _skillPointsInfo.ranking = value.getLong(PlayerVars.RANKING_PARAM);
            _skillPointsInfo.points = value.getLong(PlayerVars.POINTS_PARAM);
        }
        
        public function get activationDay():int{
            return _skillPointsInfo.activationDay;
        }
        
        public function get activationMonth():int{
            return _skillPointsInfo.activationMonth;
        }
        
        public function get activationYear():int{
            return _skillPointsInfo.activationYear;
        }
        
        public function get gamesLost():int{
            return _skillPointsInfo.gamesLost;
        }
        
        public function get gamesWon():int{
            return _skillPointsInfo.gamesWon;
        }
        
        public function get ranking():Number{
            return _skillPointsInfo.ranking;
        }
        
        public function get points():Number{
            return _skillPointsInfo.points;
        }
        
        public function get usingSkillPoints():Boolean{
            if(ConfigController.getInstance().allowRankedGames && isRegistered){
                return true;
            }else{
                return false;
            }
        }
        
        public function get pointsStr():String{
            if(isNaN(_skillPointsInfo.points)){
                return LanguageManager.getInstance().getText('_na');
            }else{
                return '' + _skillPointsInfo.points;
            }
        }
        
        public function get rankingStr():String{
            if(isNaN(_skillPointsInfo.ranking)){
                return LanguageManager.getInstance().getText('_na');
            }else if(_skillPointsInfo.ranking==-1){
                return LanguageManager.getInstance().getText('_unranked');
            }else{
                return '' + _skillPointsInfo.ranking;
            }
        }
        
        public function hasSkillpoints():Boolean{
            if(isNaN(_skillPointsInfo.points)){
                return false;
            }else{
                return true;
            }
        }
        
        public function set positionInWaitingList(value:int):void
        {
            _positionInWaitingList = value;
        }
        public function get positionInWaitingList():int
        {
            return _positionInWaitingList;
        }
        
        public function set ping(value:int):void{
            _ping = value;
            
            pingVeryHigh = false;
            pingHigh = false;
            pingLow = false;
            pingVeryLow = false;
            
            if(_ping<=40){
                pingVeryHigh = true;
            }else if(_ping<=80){
                pingHigh = true;
            }else if(_ping<=160){
                pingLow = true;
            }else{
                pingVeryLow = true;
            }
        }
        
        public function get ping():int{
            return _ping;
        }
        
        public function get nationality():String
        {
            return _nationality;
        }
        
        public function set nationality(value:String):void
        {
            _nationality = value;
        }
    }
}