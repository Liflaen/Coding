import pyglet
from pyglet import gl
from pyglet.window import key

# global variables for enviroment
width = 600
height = 400
coordianceOfSnake = [width // 2, height // 2]
sizeOfSnake = 10
speedOfSnake = 20
startingCoordiance = [0, 0]
pressed_keys = set()

def draw_snake(x1, y1, x2, y2):
    gl.glBegin(gl.GL_TRIANGLE_FAN) 
    gl.glVertex2f(int(x1), int(y1))
    gl.glVertex2f(int(x1), int(y2))
    gl.glVertex2f(int(x2), int(y2))
    gl.glVertex2f(int(x2), int(y1))
    gl.glEnd()

    print (x1, x2, y1, y2)

def draw():
    gl.glClear(gl.GL_COLOR_BUFFER_BIT)
    gl.glColor3f(0.8, 0, 0)  
    draw_snake(
        coordianceOfSnake[0] - sizeOfSnake,
        coordianceOfSnake[1] - sizeOfSnake,
        coordianceOfSnake[0] + sizeOfSnake,
        coordianceOfSnake[1] + sizeOfSnake
    )

def press_of_key(symbol, modificator):
    if symbol == key.UP:
        pressed_keys.add(('up', 1))
    if symbol == key.DOWN:
        pressed_keys.add(('down', 1))
    if symbol == key.LEFT:
        pressed_keys.add(('left', 1))
    if symbol == key.RIGHT:
        pressed_keys.add(('right', 1))

""" def release_of_key(symbol, modificator):
    if symbol == key.UP:
        pressed_keys.discard(('up', 1))
    if symbol == key.DOWN:
        pressed_keys.discard(('down', 1))
    if symbol == key.LEFT:
        pressed_keys.discard(('left', 1))
    if symbol == key.RIGHT:
        pressed_keys.discard(('right', 1))
 """
def refresh_state(dt):
    if ('up', 1) in pressed_keys:
        coordianceOfSnake[1] += dt * speedOfSnake
    if ('down', 1) in pressed_keys:
        coordianceOfSnake[1] -= dt * speedOfSnake
    if ('left', 1) in pressed_keys:
        coordianceOfSnake[0] -= dt * speedOfSnake
    if ('right', 1) in pressed_keys:
        coordianceOfSnake[0] += dt * speedOfSnake

    # set borders
    if coordianceOfSnake[1] < sizeOfSnake:
        coordianceOfSnake[1] = sizeOfSnake
    if coordianceOfSnake[1] > height - sizeOfSnake:
        coordianceOfSnake[1] = height - sizeOfSnake
    if coordianceOfSnake[0] < sizeOfSnake:
        coordianceOfSnake[0] = sizeOfSnake
    if coordianceOfSnake[0] > width - sizeOfSnake:
        coordianceOfSnake[0] = width - sizeOfSnake

window = pyglet.window.Window(width=width, height=height)
window.push_handlers(
    on_draw=draw,
    on_key_press=press_of_key,
)
pyglet.clock.schedule(refresh_state)
pyglet.app.run()