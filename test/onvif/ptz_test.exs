defmodule PTZTest do
  use ExUnit.Case
  alias EvercamMedia.ONVIFPTZ
  
  @access_info %{"url" => "http://149.13.244.32:8100", "auth" => "admin:mehcam"}
  
  test "get_nodes method on hikvision camera" do
    {:ok, response} = ONVIFPTZ.get_nodes @access_info
    assert response |> Map.get("PTZNode") |> Map.get("Name") == "PTZNODE"
    assert response |> Map.get("PTZNode") |> Map.get("token") == "PTZNODETOKEN"
  end 

  test "get_configurations method on hikvision camera" do
    {:ok, response} = ONVIFPTZ.get_configurations @access_info
    assert response |> Map.get("PTZConfiguration") |> Map.get("Name") == "PTZ"
    assert response |> Map.get("PTZConfiguration") |> Map.get("NodeToken") == "PTZNODETOKEN"
  end 

  test "get_presets method on hikvision camera" do
    {:ok, response} = ONVIFPTZ.get_presets(@access_info, "Profile_1")
    [first_preset | _] = response |> Map.get("Presets")
    assert first_preset |> Map.get("Name") == "Back Main Yard"
    assert first_preset |> Map.get("token") == "1"
  end   

  test "goto_preset method on hikvision camera" do
    {:ok, response} = ONVIFPTZ.goto_preset(@access_info, "Profile_1", "6")
    assert response == :ok
  end   

  test "set_preset and remove_preset method on hikvision camera" do
    {:ok, response} = ONVIFPTZ.set_preset(@access_info, "Profile_1")
	  preset_token = response |> Map.get("PresetToken")
    {:ok, response} = ONVIFPTZ.remove_preset(@access_info, "Profile_1", preset_token)
	  assert response == :ok
  end

  test "set_home_position method on hikvision camera" do
    {:ok, response} = ONVIFPTZ.set_home_position(@access_info, "Profile_1")
	  assert response == :ok
  end

  test "goto_home_position method on hikvision camera" do
    {:ok, response} = ONVIFPTZ.goto_home_position(@access_info, "Profile_1")
	  assert response == :ok
  end   

  test "relative_move method on hikvision camera" do
    {:ok, response} = ONVIFPTZ.relative_move(@access_info, "Profile_1", [x: 0.0, y: 0.0, zoom: 0.0])
	  assert response == :ok
  end   
  
  test "stop method on hikvision camera" do
    {:ok, response} = ONVIFPTZ.continuous_move(@access_info, "Profile_1", [x: 0.1, y: 0.0])
    assert response == :ok
    {:ok, response} = ONVIFPTZ.stop(@access_info, "Profile_1")
    assert response == :ok
  end

  test "pan_tilt coordinates available" do
    response = ONVIFPTZ.pan_tilt_zoom_vector [x: 0.5671, y: 0.9919]
    assert String.contains? response, "PanTilt"
    assert not String.contains? response, "Zoom"
  end

  test "pan_tilt coordinates and zoom available" do
    response = ONVIFPTZ.pan_tilt_zoom_vector [x: 0.5671, y: 0.9919, zoom: 1.0]
    assert String.contains? response, "Zoom"
    assert String.contains? response, "PanTilt" 
  end

  test "pan_tilt coordinates available broken but zoom ok" do
    response = ONVIFPTZ.pan_tilt_zoom_vector [x: 0.5671, zoom: 0.9919]
    assert String.contains? response, "Zoom"
    assert not String.contains? response, "PanTilt"
  end

  test "pan_tilt_zoom only zoom available" do
    response = ONVIFPTZ.pan_tilt_zoom_vector [zoom: 0.5671]
    assert String.contains? response, "Zoom"
    assert not String.contains? response, "PanTilt"
  end

  test "pan_tilt_zoom empty" do
    response = ONVIFPTZ.pan_tilt_zoom_vector []
    assert not String.contains? response, "Zoom"
    assert not String.contains? response, "PanTilt" 
  end

end

