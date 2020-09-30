#
# Set-NewAudioDeviceOutput.ps1
# version: 1.0.0
# author: Steve Harsant
# email: stevenharsant@gmail.com
#
# This script cycles through enabled audio devices.
# Requires: Burnt Toast and AudioDeviceCmdlets
#
# Burnt Toast: https://github.com/Windos/BurntToast
# AudioDeviceCmdlets: https://github.com/frgnca/AudioDeviceCmdlets

try {

  # Increment or reset index
  switch ($env:AUDIO_DEVICE_INDEX) {
    { 1 -or 2 } {
      $newIndex = [int]$env:AUDIO_DEVICE_INDEX + 1
    }
    3 {
      $newIndex = 1
    }
    Default {
      New-BurntToastNotification  -Text 'Error', 'Unknown audio index'
    }
  }

  # Set audio device and capture details about the now current device
  # Save index as a system environment variable
  $result = Set-AudioDevice -Index $newIndex
  [Environment]::SetEnvironmentVariable('AUDIO_DEVICE_INDEX', "$newIndex", "Machine")

  New-BurntToastNotification  -Text 'Audio device changed', "$($result.Name)"

  refreshenv
}
catch { Write-Error $error[0] }
