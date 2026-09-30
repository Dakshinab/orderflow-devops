package com.orderflow.controller;

import com.orderflow.model.Order;
import com.orderflow.repository.OrderRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import software.amazon.awssdk.services.sqs.SqsClient;
import software.amazon.awssdk.services.sqs.model.SendMessageRequest;

import java.util.List;

@RestController
@RequestMapping("/api/orders")
public class OrderController {

    @Autowired
    private OrderRepository orderRepository;

    private final SqsClient sqsClient = SqsClient.builder().build();
    private final String queueUrl = "https://sqs.ap-south-1.amazonaws.com/223767250051/orderflow-order-queue";

    @GetMapping
    public List<Order> getAllOrders() {
        return orderRepository.findAll();
    }

    @PostMapping
    public Order createOrder(@RequestBody Order order) {
        Order savedOrder = orderRepository.save(order);

        sqsClient.sendMessage(SendMessageRequest.builder()
                .queueUrl(queueUrl)
                .messageBody("Order ID: " + savedOrder.getId() + " needs processing")
                .build());

        return savedOrder;
    }

    @GetMapping("/health")
    public String health() {
        return "OrderFlow API is running";
    }
}
