package org.acme;

import io.debezium.outbox.quarkus.ExportedEvent; 
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.enterprise.event.Event;
import jakarta.inject.Inject;
import jakarta.transaction.Transactional;
import java.time.Instant;

@ApplicationScoped
public class OrderService {
    @Inject
    OrderRepository orderRepository;

    @Inject
    Event<ExportedEvent<?, ?>> event;

    @Transactional
    public Order addOrder(Order order) {
        orderRepository.persist(order);
        event.fire(new OrderCreatedEvent(Instant.now(), order));
        return order;
    }
}
