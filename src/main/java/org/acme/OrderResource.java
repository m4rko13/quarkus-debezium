package org.acme;

import io.debezium.outbox.quarkus.ExportedEvent;
import jakarta.enterprise.event.Event;
import jakarta.inject.Inject;
import jakarta.persistence.EntityManager;
import jakarta.transaction.Transactional;
import jakarta.ws.rs.*;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;
import java.time.Instant;
import java.util.List;

@Path("/order")
@Consumes(MediaType.APPLICATION_JSON)
@Produces(MediaType.APPLICATION_JSON)
public class OrderResource {
    @Inject
    OrderService orderService;
    
    @Inject
    EntityManager entityManager;
    
    @Inject
    Event<ExportedEvent<?, ?>> event;

    @POST
    public Order createOrder(Order order) {
        return orderService.addOrder(order);
    }
    
    @GET
    @Path("/debug/tables")
    public Response checkTables() {
        try {
            String sql = "SELECT table_name FROM information_schema.tables WHERE table_schema = 'public'";
            List<String> tables = entityManager.createNativeQuery(sql).getResultList();
            return Response.ok(tables).build();
        } catch (Exception e) {
            return Response.serverError().entity("Error: " + e.getMessage()).build();
        }
    }
    
    @GET
    @Path("/debug/outbox")
    public Response checkOutbox() {
        try {
            String sql = "SELECT COUNT(*) FROM outboxevent";
            Object count = entityManager.createNativeQuery(sql).getSingleResult();
            return Response.ok("Outbox records: " + count).build();
        } catch (Exception e) {
            return Response.serverError().entity("Error: " + e.getMessage()).build();
        }
    }
    
    @POST
    @Path("/debug/fire-event")
    @Transactional
    public Response fireEvent() {
        try {
            System.out.println("🔥 DEBUG: Manually firing OrderCreatedEvent");
            Order testOrder = new Order();
            testOrder.setId(999L);
            testOrder.setNumber("DEBUG-MANUAL");
            testOrder.setCustomerId("DEBUG-MANUAL-CUSTOMER");
            
            OrderCreatedEvent testEvent = new OrderCreatedEvent(Instant.now(), testOrder);
            event.fire(testEvent);
            System.out.println("🔥 DEBUG: Event fired successfully");
            
            return Response.ok("Event fired manually").build();
        } catch (Exception e) {
            System.out.println("🔥 DEBUG ERROR: " + e.getMessage());
            return Response.serverError().entity("Error: " + e.getMessage()).build();
        }
    }
}
