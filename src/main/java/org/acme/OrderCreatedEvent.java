package org.acme;
import io.debezium.outbox.quarkus.ExportedEvent;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.node.ObjectNode;
import com.fasterxml.jackson.databind.node.JsonNodeFactory;
import java.time.Instant;
import java.util.Collections;
import java.util.Map;

public class OrderCreatedEvent implements ExportedEvent<String, JsonNode> {
    private static final String TYPE = "Order";
    private static final String EVENT_TYPE = "OrderCreated";
    
    private final String orderId;
    private final JsonNode payload;
    private final Instant timestamp;
    
    public OrderCreatedEvent(Instant createdAt, Order order) {
        this.orderId = order.getId().toString();
        
        // Create an ObjectNode instead of JsonNode for mutability
        ObjectNode node = JsonNodeFactory.instance.objectNode();
        node.put("id", order.getId());
        node.put("number", order.getNumber());
        node.put("customerId", order.getCustomerId());
        
        this.payload = node;
        this.timestamp = createdAt;
    }
    
    @Override
    public String getAggregateId() {
        return orderId;
    }
    
    @Override
    public String getAggregateType() {
        return TYPE;
    }
    
    @Override
    public JsonNode getPayload() {
        return payload;
    }
    
    @Override
    public String getType() {
        return EVENT_TYPE;
    }
    
    @Override
    public Instant getTimestamp() {
        return timestamp;
    }
    
    @Override
    public Map<String, Object> getAdditionalFieldValues() {
        return Collections.emptyMap();
    }
}