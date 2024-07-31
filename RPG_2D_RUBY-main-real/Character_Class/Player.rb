require 'ruby2d'
require_relative '../ImageHandler' # to read dimemsion of image ==> must install (gem install rmagick)
require_relative '../CollisionChecker'
require_relative '../CommonParameter'
require_relative '../Item_Class/Player_Inventory'


require_relative 'HealthBar'
include CCHECK




class Player
  attr_reader :x, :y,
              :worldX, :worldY,
              :speed,
              :collision_with_monster_index
              :collision_with_npc_index
              :collision_with_item_index
              :attack

  attr_accessor :upDirection, :downDirection, :leftDirection, :rightDirection,
                :solidArea,
                :collisionOn,
                :myInventory,
                :interacting,
                :talktoNpc,
                :healthBar


  def initialize(worldX, worldY, width, height)

    
    #1. Image and Animation
    
    @image = Sprite.new(
      'Image/Player.png',
      x: CP::SCREEN_WIDTH / 2 - (CP::TILE_SIZE/2) - 25, # (768/2) - (48/2) = 360
      y: CP::SCREEN_HEIGHT / 2 - (CP::TILE_SIZE/2) - 20, # (576/2) - (48/2) = 264
      z: 20,                                                            #Precedence of show
      width: width*2, height: height*2, 
      animations: {
        static: [
          {
            x: 0, y: 0,
            width: 192, height: 192,
            time: 100
          },

          {
            x: 192, y: 0,
            width: 192, height: 192,
            time: 100
          },

          {
            x: 384, y: 0,
            width: 192, height: 192,
            time: 100
          },

          {
            x: 576, y: 0,
            width: 192, height: 192,
            time: 100
          },

          {
            x: 768, y: 0,
            width: 192, height: 192,
            time: 100
          },

          {
            x: 960, y: 0,
            width: 192, height: 192,
            time: 100
          }
        ],

        walk: [
          {
            x: 0, y: 192,
            width: 192, height: 192,
            time: 100
          },

          {
            x: 192, y: 192,
            width: 192, height: 192,
            time: 100
          },

          {
            x: 384, y: 192,
            width: 192, height: 192,
            time: 100
          },

          {
            x: 576, y: 192,
            width: 192, height: 192,
            time: 100
          },

          {
            x: 768, y: 192,
            width: 192, height: 192,
            time: 100
          },

          {
            x: 960, y: 192,
            width: 192, height: 192,
            time: 100
          }
        ],

        attackSide: [
          {
            x: 0, y: 192*2,
            width: 192, height: 192,
            time: 50
          },

          {
            x: 192, y: 192*2,
            width: 192, height: 192,
            time: 50
          },

          {
            x: 384, y: 192*2,
            width: 192, height: 192,
            time: 50
          },

          {
            x: 576, y: 192*2,
            width: 192, height: 192,
            time: 50
          },

          {
            x: 768, y: 192*2,
            width: 192, height: 192,
            time: 50
          },

          {
            x: 960, y: 192*2,
            width: 192, height: 192,
            time: 50
          },
        ],
      }
       
    )
    @image.play(animation: :static, loop: true)


    @x =  CP::SCREEN_WIDTH / 2 - (CP::TILE_SIZE/2)
    @y = CP::SCREEN_HEIGHT / 2 - (CP::TILE_SIZE/2)


    #2. Health Bar
    @healthBar = HealthBar.new(
      200,
      200,
      CP::SCREEN_WIDTH / 2 - (CP::TILE_SIZE/2) - (width*2/3),
      CP::SCREEN_HEIGHT / 2 - (CP::TILE_SIZE/2) - 10,
      100
    )
    @healthBar.heart.x = CP::SCREEN_WIDTH / 2 - (CP::TILE_SIZE/2) - (width*2/3) - 15

    #3. Speed
    @speed = 3

    #4. Direction and Facing
    @facing = 'right'
    @upDirection = false
    @downDirection = false
    @leftDirection = false
    @rightDirection = false

    #5. World Coordinate
    @worldX = worldX
    @worldY = worldY

    #6. Solid Area to check collision with other objects
    @solidArea = Rectangle.new(
      x: 8, y: 16,            # Position
      width: 32, height: 32,  # Size
      opacity: 0
    )


    @hitBox = Rectangle.new(
      x: CP::SCREEN_WIDTH / 2 - (CP::TILE_SIZE/2) + 8, y: CP::SCREEN_HEIGHT / 2 - (CP::TILE_SIZE/2) + 16,            # Position
      width: 32, height: 32,  # Size
      opacity: 1
    )


    #7. State of Collision
    @collisionOn = false                            # Whenever player collides any objects (NPCs, Items, Monsters), this will turn true, otherwise false.
    @collision_with_monster_index = -1              # When collision with Monster. The collided Monster is identified by array index
    @collision_with_npc_index = -1                  # When collision with NPC. The collided NPC is identified by array index
    @collision_with_item_index = -1                 # When collision with Item. The collided Item is identified by array index

    #8. State of interaction
    @interacting
    @talktoNpc

    #9. Inventory
    @myInventory = Inventory.new()

    #10. Attack damage
    @attack = 25

    #11. Attack boxes
    @attackBoxRight = Rectangle.new(
      x: 360+48, y: 264-48,
      width: 50 + 15, height: 50+48*2,
      opacity: 0
    )

    @attackBoxLeft = Rectangle.new(
      x: 360-48-15, y: 264-48,
      width: 50 + 15, height: 50+48*2,
      opacity: 0
    )

    @attackBoxSpecial = Rectangle.new(
      x: 360-48-15, y: 264-48,
      width: 177, height: 50+48*2,
      opacity: 0
    )

  end


#-------------------------------- Very Usefull Methods -----------------------------------------

  def checkCollision(monsters, map, items, npcs)

    @collisionOn = false
    @collision_with_monster_index = -1
    @collision_with_npc_index = -1
    @collision_with_item_index = -1

    #1. Check if player collides any wall
    CCHECK.checkTile(self, map)

    #2. Check if player collides any Monster
    @collision_with_monster_index = CCHECK.checkEntity_Collide_AllTargets(self, monsters)

    #3. Check if monster collides any Item in the map
    @collision_with_item_index = CCHECK.checkEntity_Collide_AllTargets(self, items)

    #4. Check if player collides any NPC in the map
    @collision_with_npc_index = CCHECK.checkEntity_Collide_AllTargets(self, npcs)

  end


#-------------------------------- Update -----------------------------------------
  def updatePlayer(monsters, map, npcs, items)

    #1. update health bar
    self.healthBar.update()
    #2. Move
    self.move(monsters, map, npcs, items)

  end



#-------------------------------- Move -----------------------------------------
  def move(monsters, map, npcs, items)

    #Check Collision before moving
    checkCollision(monsters, map, items, npcs)

    #If no collision is detected, then let player move
    if(@collisionOn == false)
      if(self.upDirection == true)
        @worldY -= @speed
      end
      if(self.downDirection == true)
        @worldY += @speed
      end
      if(self.leftDirection == true)
        @worldX -= @speed
      end
      if(self.rightDirection == true)
        @worldX += @speed
      end
    end
  end
#-------------------------------- Attack and Special Skills -----------------------------------------

def attackInBox(monsters)
  
  case @facing
  when 'right'
    @image.play(animation: :attackSide) do
      monsters.each do |monster|
        if CCHECK.intersect(@attackBoxRight.x,@attackBoxRight.y,@attackBoxRight.width,@attackBoxRight.height,
          monster.hitBox.x,monster.hitBox.y,monster.hitBox.width,monster.hitBox.height)
          monster.beAttacked(@attack)
        end
      end
    end
  when 'left'
    @image.play(animation: :attackSide, flip: :horizontal) do
      monsters.each do |monster|
        if CCHECK.intersect(@attackBoxLeft.x,@attackBoxLeft.y,@attackBoxLeft.width,@attackBoxLeft.height,
          monster.hitBox.x,monster.hitBox.y,monster.hitBox.width,monster.hitBox.height)
          monster.beAttacked(@attack)
        end
      end
    end
  end
end

def attackSpecial(monsters)

end

def beAttacked(ammounts)
  @healthBar.hp -= ammounts
end

#-------------------------------- Setter Methods -----------------------------------------

  def runAnimation()
    case @facing
    when 'right'
      if @leftDirection
        @facing = 'left'
        @image.play animation: :walk, loop: true, flip: :horizontal
      else
        @image.play(animation: :walk)
      end
    when 'left'
      if @rightDirection
        @image.play(animation: :walk)
        @facing = 'right'
      else
        @image.play animation: :walk, loop: true, flip: :horizontal
      end
    end
  end

#-------------------------------- Stop Moving -----------------------------------------

  def stop()
    case @facing
    when 'right'
      @image.play(animation: :static, loop: true)
    when 'left'
      @image.play(animation: :static, loop: true, flip: :horizontal)
    end
  end

end
