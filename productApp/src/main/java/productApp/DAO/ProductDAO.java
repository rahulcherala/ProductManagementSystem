package productApp.DAO;

import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import productApp.constants.CommonConstants;
import productApp.model.Product;

import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;
import java.util.List;

@Repository
@Transactional
public class ProductDAO {

    @PersistenceContext
    private EntityManager em;

    public List<Product> getAll() {
        return em.createQuery("SELECT p FROM Product p", Product.class).getResultList();
    }

    public void add(Product p) {
        em.persist(p);
    }

    public Product getById(int id) {
        return em.find(Product.class, id);
    }

    public void update(Product p) {
        em.merge(p);
    }

    public void delete(int id) {
        Product p = em.find(Product.class, id);
        if (p != null) em.remove(p);
    }

    // ✅ Used only for "new product" validation
    public boolean existsByName(String name) {
        Long count = em.createQuery("SELECT COUNT(p) FROM Product p WHERE p.name = :name", Long.class)
                       .setParameter("name", name)
                       .getSingleResult();
        return count > CommonConstants.zero;
    }

    // ✅ New: find product by name (used in edit form validation)
    public Product findByName(String name) {
        List<Product> results = em.createQuery("SELECT p FROM Product p WHERE p.name = :name", Product.class)
                                  .setParameter("name", name)
                                  .setMaxResults(1)
                                  .getResultList();
        return results.isEmpty() ? null : results.get(0);
    }

    public List<Product> getProducts(int offset, int limit) {
        return em.createQuery("SELECT p FROM Product p ORDER BY p.id", Product.class)
                 .setFirstResult(offset)
                 .setMaxResults(limit)
                 .getResultList();
    }

    public int getTotalCount() {
        Long count = em.createQuery("SELECT COUNT(p) FROM Product p", Long.class).getSingleResult();
        return count.intValue();
    }
}
