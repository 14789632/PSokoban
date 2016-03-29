## TO BE DONE
# Needs to check if another level exists
# Fix checking if the crates are all in the proper place automatically instead of pressing ENTER

#"Imports"
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Windows.Forms

# Loop condition
$global:done = $false

# First level filename
$global:progress = 1
$global:filename = "level"

# Properly placed boxes counter
$global:wincounter = 0

# Create pen and brush objects 
$blackBrush = New-Object Drawing.SolidBrush black
$bgBrush = New-Object Drawing.SolidBrush blue
$wallBrush = New-Object Drawing.SolidBrush red
$floorBrush = New-Object Drawing.SolidBrush brown
$ballBrush = New-Object Drawing.SolidBrush orange
$goalBrush = New-Object Drawing.SolidBrush lime
$playerBrush = New-Object Drawing.SolidBrush white
#$mypen = New-Object Drawing.Pen black

# Create a Form
$form = New-Object Windows.Forms.Form
$form.Width = 400
$form.Height = 400
$form.FormBorderStyle = 'FixedDialog'
$form.StartPosition = "CenterScreen"
$form.ControlBox = $false
$form.Text = "PSokoban"
$form.BackColor = "Blue"

# Setting Form icon
$icon = [system.drawing.icon]::ExtractAssociatedIcon($PSHOME + "\powershell.exe")
$form.Icon = $icon

# Setting key event handling to ON
$form.KeyPreview = $true

# Creating graphics for use in the form
$formGraphics = $form.createGraphics()

function KeyboardEvents{
	# Keyboard events handling

	# Escape key
	# Arrows are: left-37, up-38, right-39, down-40
	$form.Add_KeyDown({
	if ($_.KeyCode -eq 27) {
			$global:done = $true
			$form.Close()
		}
	})
#Victory function
	$form.Add_KeyDown({
	if ($_.KeyCode -eq "Enter") {
			CheckWin
			#Write-Host "Wincounter: ", $global:wincounter
			#Write-Host "Goals: ", $global:goals
			#Write-Host "Balls: ", $global:balls
			[System.Media.SystemSounds]::Asterisk.Play();
			$form.Refresh()
		} 
	})#>
	$form.Add_KeyDown({
	if ($_.KeyCode -eq 37) {
			#Move left
			if($level[$locationx,($locationy-1)] -eq 'F' -or $level[$locationx,($locationy-1)] -eq 'X'){
				$global:locationy -= 1			
			}
			elseif($level[$locationx,($locationy-1)] -eq 'O'){
				foreach($ball in $global:balls){
					if($ball[0] -eq $locationx -and $ball[1] -eq ($locationy-1) -and $level[$locationx,($locationy-2)] -ne "W" -and $level[$locationx,($locationy-2)] -ne "O"){
						$global:locationy -= 1
						$ball[1] -= 1
						$level[$locationx,$locationy] = "F"
						$level[$locationx,($locationy-1)] = "O"
						break
					}
				}
			}
			#Write-Host "Player position: ", $locationx, $locationy
			$form.Refresh()
		}
	})
	$form.Add_KeyDown({
	if ($_.KeyCode -eq 38) {
			#Move up
			if($level[($locationx-1),$locationy] -eq 'F' -or $level[($locationx-1),$locationy] -eq 'X'){
				$global:locationx -= 1
			}
			elseif($level[($locationx-1),$locationy] -eq 'O'){
				foreach($ball in $global:balls){
					if($ball[0] -eq ($locationx-1) -and $ball[1] -eq $locationy -and $level[($locationx-2),$locationy] -ne "W" -and $level[($locationx-2),$locationy] -ne "O"){
						$global:locationx -= 1
						$ball[0] -= 1
						$level[$locationx,$locationy] = "F"
						$level[($locationx-1),$locationy] = "O"
						break
					}
				}
			}
			#Write-Host "Player position: ", $locationx, $locationy
			$form.Refresh()
		}
	})
	$form.Add_KeyDown({
	if ($_.KeyCode -eq 39) {
			#Move right
			if($level[$locationx,($locationy+1)] -eq 'F' -or $level[$locationx,($locationy+1)] -eq 'X'){
				$global:locationy += 1
			}
			elseif($level[$locationx,($locationy+1)] -eq 'O'){
				foreach($ball in $global:balls){
					if($ball[0] -eq $locationx -and $ball[1] -eq ($locationy+1) -and $level[$locationx,($locationy+2)] -ne "W" -and $level[$locationx,($locationy+2)] -ne "O"){
						$global:locationy += 1
						$ball[1] += 1
						$level[$locationx,$locationy] = "F"
						$level[$locationx,($locationy+1)] = "O"
						break
					}
				}
			}
			#Write-Host "Player position: ", $locationx, $locationy
			$form.Refresh()
		}
	})
	$form.Add_KeyDown({
	if ($_.KeyCode -eq 40) {
			#Move down
			if($level[($locationx+1),$locationy] -eq 'F' -or $level[($locationx+1),$locationy] -eq 'X'){
				$global:locationx += 1
			}
			elseif($level[($locationx+1),$locationy] -eq 'O'){
				foreach($ball in $global:balls){
					if($ball[0] -eq ($locationx+1) -and $ball[1] -eq $locationy -and $level[($locationx+2),$locationy] -ne "W" -and $level[($locationx+2),$locationy] -ne "O"){
						$global:locationx += 1
						$ball[0] += 1
						$level[$locationx,$locationy] = "F"
						$level[($locationx+1),$locationy] = "O"
						break
					}
				}
			}
			#Write-Host "Player position: ", $locationx, $locationy
			$form.Refresh()
		}
	})
	# Restart current level
	$form.Add_Keydown({
	if($_.KeyCode -eq 82){
		LevelLoad
		$form.Refresh()
	}
	})
}

function Graphics{
	if($global:done -eq $false){
		$form.Add_Paint({
			for($i = 0; $i -lt 20; $i = $i + 1){
				for($j = 0; $j -lt 20; $j = $j +1){
					if($level[$j,$i] -eq 'W' -and $global:firstrun -eq $true){
						$formGraphics.FillRectangle($wallBrush, $i*20, $j*20, 20, 20)
					}
				}
			}
			foreach($tile in $global:floor){
				$formGraphics.FillRectangle($floorBrush, $tile[1]*20, $tile[0]*20, 20, 20)
			}
			foreach($goal in $global:goals){
				$formGraphics.FillRectangle($goalBrush, $goal[1]*20, $goal[0]*20, 20, 20)
			}
			foreach($ball in $global:balls){
				$formGraphics.FillRectangle($ballBrush, $ball[1]*20, $ball[0]*20, 20, 20)
			}
			# Draw player
			$formGraphics.FillRectangle($playerBrush, $locationy*20, $locationx*20, 20, 20)
		})
	}

	$form.ShowDialog()   # display the dialog
}

function LevelLoad{

	# Less refreshing
	$global:firstrun = $true

	# Load the level
	$levelfile = @()
	$levelfile = Get-Content ($global:filename+$global:progress)
	$global:level = New-Object 'object[,]' 20,20 #empty 2d 20x20 array
	$global:goals = @()
	$global:balls = @()
	$global:floor = @()
	$global:walls = @()
	$tmp = @()

	for($i = 0; $i -lt 20; $i = $i + 1){
		$tmp = $levelfile[$i].ToCharArray()
		for($j = 0; $j -lt 20; $j = $j + 1){
			$global:level[$i,$j] = $tmp[$j]
			if($level[$i,$j] -eq "@"){
				$global:locationx = $i
				$global:locationy = $j
		# later on the player is treated like an entity seperate to the level
				$level[$i,$j] = "F"
				$global:floor += (,($i,$j))
			}
			elseif($level[$i,$j] -eq "X"){
				$global:goals += (,($i,$j))
			}
			elseif($level[$i,$j] -eq "F"){
				$global:floor += (,($i,$j))
			}
			elseif($level[$i,$j] -eq "O"){
				$global:balls += (,($i,$j))
				$global:floor += (,($i,$j))
			}
		}
	}
	# Testing
	#Write-Host $locationx, $locationy
	#Write-Host $global:goals
	#Write-Host $global:balls
	#Write-Host $global:floor
}

function CheckWin{
	if(@(Compare-Object $global:balls $global:goals).Length -eq 0){
		[System.Media.SystemSounds]::Asterisk.Play();
		$global:progress += 1
		LevelLoad
	}
}

while($global:done -eq $false){
	if($global:progress -eq 1){LevelLoad}
	CheckWin
	KeyboardEvents
	Graphics
} 

