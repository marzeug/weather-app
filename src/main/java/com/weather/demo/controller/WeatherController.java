package com.weather.demo.controller;

import com.weather.demo.model.WeatherResponse;
import com.weather.demo.service.WeatherService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/weather")
public class WeatherController {

    @Autowired
    private WeatherService weatherService;

    // Endpoint : GET /api/weather?city=Paris
    @GetMapping
    public WeatherResponse getWeather(@RequestParam String city) {
        return weatherService.getWeather(city);
    }

    // Endpoint santé : GET /api/weather/health
    @GetMapping("/health")
    public String health() {
        return "OK";
    }
}