--[[
    ScoreState Class
    Author: Colton Ogden
    cogden@cs50.harvard.edu

    A simple state used to display the player's score before they
    transition back into the play state. Transitioned to from the
    PlayState when they collide with a Pipe.
]]

ScoreState = Class{__includes = BaseState}

medals = {
    ['bronze'] = love.graphics.newImage('bronze.png'),
    ['silver'] = love.graphics.newImage('silver.png'),
    ['gold'] = love.graphics.newImage('gold.png'),
    ['bwav'] = love.audio.newSource('bronze.wav', 'static'),
    ['swav'] = love.audio.newSource('silver.wav', 'static'),
    ['gwav'] = love.audio.newSource('gold.wav', 'static')
}

function ScoreState:init()
    self.timer = 0
    self.medal = 0
    self.scoreParams = 3
    self.bmed = 0
    self.smed = 0
    self.gmed = 0
end

--[[
    When we enter the score state, we expect to receive the score
    from the play state so we know what to render to the State.
]]
function ScoreState:enter(params)
    self.score = params.score
end

function ScoreState:update(dt)
    self.timer = self.timer + dt

    if self.timer > 1.2 then
        if self.score >= self.scoreParams then
            self.medal = self.medal + 1
            self.scoreParams = self.scoreParams + 3
        end
        self.timer = 0
    end

    -- go back to play if enter is pressed
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        gStateMachine:change('countdown')
    end
end

function ScoreState:render()
    -- simply render the score to the middle of the screen
    love.graphics.setFont(flappyFont)
    love.graphics.printf('Oof! You lost!', 0, 64, VIRTUAL_WIDTH, 'center')

    love.graphics.setFont(mediumFont)
    love.graphics.printf('Score: ' .. tostring(self.score), 0, 100, VIRTUAL_WIDTH, 'center')

    if self.medal > 0 then
        love.graphics.draw(medals['bronze'], VIRTUAL_WIDTH / 3 - 64, 170)
        if self.bmed == 0 then
            medals['bwav']:play()
            self.bmed = self.bmed + 1
        end
        if self.medal > 1 then
            love.graphics.draw(medals['silver'], VIRTUAL_WIDTH / 3 * 2 - 32, 170)
            if self.smed == 0 then
                medals['swav']:play()
                self.smed = self.smed + 1
            end
            if self.medal > 2 then
                love.graphics.draw(medals['gold'], VIRTUAL_WIDTH / 2 - 48, 170)
                if self.gmed == 0 then
                    medals['gwav']:play()
                    self.gmed = self.gmed + 1
                end
            end
        end
    end

    love.graphics.printf('Press Enter to Play Again!', 0, 160, VIRTUAL_WIDTH, 'center')
end