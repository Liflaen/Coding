import arcade
import os

SCREEN_WIDTH = 800
SCREEN_HEIGHT = 600
SPRITE_SCALLING = 0.65
MOVEMENT_SPEED = 5

class MyGame (arcade.Window):
    def __init__(self, width, height):
        super().__init__(width, height)
        
        file_path = os.path.dirname(os.path.abspath(__file__))
        os.chdir(file_path)

        self.player_list = None
        self.wall_list = None
        self.physics_engine = None

    def setup(self):
        self.player_list = arcade.SpriteList()
        self.wall_list = arcade.SpriteList()

        self.player_sprite = arcade.Sprite("images/boxCrate_double.png", SPRITE_SCALLING)
        self.player_sprite.center_x = 50
        self.player_sprite.center_y = 64
        self.player_list.append(self.player_sprite)

        for x in range(173, 650, 64):
            wall = arcade.Sprite("images/boxCrate_double.png", SPRITE_SCALLING)
            wall.center_x = x
            wall.center_y = 200
            self.wall_list.append(wall)
        
        self.physics_engine = arcade.PhysicsEngineSimple(self.player_sprite, self.wall_list)
        arcade.set_background_color(arcade.color.AMAZON)

    def on_draw(self):
        arcade.start_render()
        self.wall_list.draw()
        self.player_list.draw()
    
    def on_key_press(self, key, modifiers):
        if key == arcade.key.UP:
            self.player_sprite.change_y = MOVEMENT_SPEED
        elif key == arcade.key.DOWN:
            self.player_sprite.change_y = -MOVEMENT_SPEED
        elif key == arcade.key.LEFT:
            self.player_sprite.change_x = -MOVEMENT_SPEED
        elif key == arcade.key.RIGHT:
            self.player_sprite.change_x = MOVEMENT_SPEED

    def on_key_release(self, key, modifiers):
        if key == arcade.key.UP or key == arcade.key.DOWN:
            self.player_sprite.change_y = 0
        elif key == arcade.key.LEFT or key == arcade.key.RIGHT:
            self.player_sprite.change_x = 0

    def update(self, delta_time):
        self.physics_engine.update()

def main():
    game = MyGame (SCREEN_WIDTH, SCREEN_HEIGHT)
    game.setup()
    arcade.run()

main()