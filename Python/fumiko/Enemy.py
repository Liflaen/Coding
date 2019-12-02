import pygame
from pygame.locals import *
import Object

class Enemy(Object.Object):
	def __init__(self):
		Object.Object.__init__(self)
		self.WALKSPEED = 2 # default walkspeed
		self.RUNSPEED = 4 # default runspeed
		self.JUMPSPEED = 3 # default jumpspeed
		self.moveSpeed = self.WALKSPEED
		self.AnimationSpeed = 150
		
		self.Charset = pygame.surface.Surface((0,0))
		self.Frame_Dict = {}
		self.Animations = {}
		
		self.Name = ""
		self.Health = 0
		self.Mana = 0

		self.Jump = False
		self.JumpHeight = 0
		self.currentTileHeight = 0 # TILE the enemy stands on
		
		self.Wall_on_Right = False
		self.Wall_on_Left = False
		
		self.currentFrame = 'Right_N'
		self.Facing = 'Right'
		self.currentState = 'Waiting'
		
		self.time_since_last_update = 0
		self.AI_type = 'walk_to_next_wall'
		
	def Move(self, Terrain):
		if self.moveDown:
			self.Y += self.Weight
		
		if not self.Wall_on_Right:
			if self.moveRight:
				self.X += self.moveSpeed
				self.Wall_on_Left = False
			elif self.moveRight:
				self.X += self.moveSpeed
				self.Wall_on_Left = False
			
		if self.Wall_on_Left == False:
			if self.moveLeft:
				self.X -= self.moveSpeed
				self.Wall_on_Right = False
			elif self.moveLeft:
				self.X -= self.moveSpeed
				self.Wall_on_Right = False
				
	def draw(self, surface):
		self.Rect = self.build_rectangle()
		surface.blit(self.Frame_Dict[self.currentFrame], self.Rect)
		return surface
			
	def build_rectangle_with_offset(self, OFFSETX, OFFSETY, BIGGERX, BIGGERY):
		# returns a modified rectangle of the enemy (for collision)
		Rectangle = pygame.Rect(self.X + OFFSETX, self.Y + OFFSETY, self.Width + BIGGERX, self.Height + BIGGERY)
		return Rectangle	
	
	def build_frame(self, x, y):
		# Returns a Rect to cut out a frame from a charset
		Rectangle = pygame.Rect(x, y, self.Width, self.Height)
		return Rectangle
		
	def get_frame(self, string):
		# Returns a surface Object of a named frame
		return self.Frame_Dict[string]
	
	def set_state(self, state):
		# some sugar
		self.currentState = state
		
	def Make_Move(self):
		if self.AI_type == 'walk_to_next_wall':
			if not self.Wall_on_Right and not self.moveLeft:
				self.moveRight = True
			elif not self.Wall_on_Left:
				self.moveRight = False
				self.moveLeft = True
				self.Wall_on_Left = False
			else:
				self.moveLeft = False
				self.moveRight = True
				self.Wall_on_Left = False

	def update_frame(self, t):
		if not (self.currentState == 'Running' or self.currentState == 'Jumping'):
			""" Animation for normal Walking starts here """
			if not (self.moveRight and self.moveLeft):
				if self.moveRight:
					self.Facing = 'Right'
					if t - self.time_since_last_update > self.AnimationSpeed:
						pointer = self.Animations['moveRight_pointer']
						self.currentFrame = self.Animations['moveRight'][pointer]
						if self.Animations['moveRight_pointer'] < len(self.Animations['moveRight']) - 1:
							self.Animations['moveRight_pointer'] += 1
						else:
							self.Animations['moveRight_pointer'] = 0
						self.time_since_last_update = t
				elif self.moveLeft:
					self.Facing = 'Left'
					if t - self.time_since_last_update > self.AnimationSpeed:
						pointer = self.Animations['moveLeft_pointer']
						self.currentFrame = self.Animations['moveLeft'][pointer]
						if self.Animations['moveLeft_pointer'] < len(self.Animations['moveRight']) - 1:
							self.Animations['moveLeft_pointer'] += 1
						else:
							self.Animations['moveLeft_pointer'] = 0
						self.time_since_last_update = t
			else:
					if self.Facing == 'Right':
						self.currentFrame = 'Right_N'
					elif self.Facing == 'Left':
						self.currentFrame = 'Left_N'
			""" Animation for normal Walking stops here """
