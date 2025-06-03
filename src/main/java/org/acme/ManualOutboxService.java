package org.acme;

import io.debezium.outbox.quarkus.ExportedEvent;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.enterprise.event.Observes;
import jakarta.inject.Inject;
import jakarta.persistence.EntityManager;
import jakarta.persistence.Query;
import jakarta.transaction.Transactional;
import java.time.Instant;
import java.util.UUID;

@ApplicationScoped
public class ManualOutboxService {
    
    @Inject
    EntityManager entityManager;
    
    @Transactional
    public void onExportedEvent(@Observes ExportedEvent<?, ?> event) {
        try {
            System.out.println("🔥 ManualOutboxService: Processing event " + event.getType());
            
            String sql = """
                INSERT INTO outboxevent (id, aggregatetype, aggregateid, type, timestamp, payload)
                VALUES (?, ?, ?, ?, ?, ?)
                """;
            
            Query query = entityManager.createNativeQuery(sql);
            query.setParameter(1, UUID.randomUUID());
            query.setParameter(2, event.getAggregateType());
            query.setParameter(3, event.getAggregateId());
            query.setParameter(4, event.getType());
            query.setParameter(5, java.sql.Timestamp.from(Instant.now()));
            query.setParameter(6, event.getPayload().toString());
            
            int result = query.executeUpdate();
            System.out.println("🔥 ManualOutboxService: Inserted " + result + " record");
            
        } catch (Exception e) {
            System.out.println("🔥 ManualOutboxService ERROR: " + e.getMessage());
            e.printStackTrace();
        }
    }
}