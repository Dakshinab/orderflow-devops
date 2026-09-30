package com.orderflow.worker;

import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import software.amazon.awssdk.services.sqs.SqsClient;
import software.amazon.awssdk.services.sqs.model.*;

import java.util.List;

@Component
public class OrderWorker {

    private final SqsClient sqsClient = SqsClient.builder().build();
    private final String queueUrl = "https://sqs.ap-south-1.amazonaws.com/223767250051/orderflow-order-queue";

    @Scheduled(fixedDelay = 5000)
    public void pollQueue() {
        ReceiveMessageRequest receiveRequest = ReceiveMessageRequest.builder()
                .queueUrl(queueUrl)
                .maxNumberOfMessages(5)
                .build();

        List<Message> messages = sqsClient.receiveMessage(receiveRequest).messages();

        for (Message message : messages) {
            System.out.println("Worker processing: " + message.body());

            sqsClient.deleteMessage(DeleteMessageRequest.builder()
                    .queueUrl(queueUrl)
                    .receiptHandle(message.receiptHandle())
                    .build());
        }
    }
}
